/**
 * FairChainLottery 前端逻辑（ethers v6）
 * ----------------------------------------
 * 面向嵌入式 / Web3 初学者的阅读顺序建议：
 * 1) 先看 HTML 里「使用说明」折叠区，理解页面要做什么。
 * 2) 从 connectWallet() 开始往下读：连接钱包 → 读合约 → 发交易。
 * 3) 遇到不认识的 API，查 ethers 文档：Provider / Contract / parseEther。
 */

/** 最小 ABI：只声明本页会用到的函数，减小体积，部署地址换链后仍可用 */
const LOTTERY_ABI = [
  "function entryFee() view returns (uint256)",
  "function lotteryState() view returns (uint8)",
  "function recentWinner() view returns (address)",
  "function latestRequestId() view returns (uint256)",
  "function enter() payable",
  "function startLottery()",
  "function endLottery()",
  "function getPlayers() view returns (address[])",
  "function owner() view returns (address)",
];

/**
 * VRF Coordinator 常见自定义错误（用于解码 unknown custom error）
 * 签名需与链上 Coordinator 一致；不完整时仍会显示原始 data。
 */
const VRF_COORDINATOR_ERRORS = [
  "error InsufficientBalance(uint256 have, uint256 want)",
  "error InvalidConsumer(uint256 subId, address consumer)",
  "error InvalidSubscription(uint256 subId)",
  "error ConsumerNotFound(uint256 subId, address consumer)",
  "error InvalidRequestID(uint256 requestId)",
  "error MustBeSubOwner(address owner)",
  "error TooManyConsumers()",
  "error MsgDataTooBig()",
  "error IncorrectCommitment()",
  "error BlockhashNotInStore(uint256 blockNum)",
];

const VRF_ERROR_IFACE = (() => {
  try {
    return new ethers.Interface(VRF_COORDINATOR_ERRORS);
  } catch {
    return null;
  }
})();

/** 与 Solidity 中 enum LOTTERY_STATE 顺序一致：OPEN=0, CLOSED=1, CALCULATING=2 */
const STATE = { OPEN: 0, CLOSED: 1, CALCULATING: 2 };

const els = {
  contractInput: document.getElementById("contractAddress"),
  connectBtn: document.getElementById("connectBtn"),
  refreshBtn: document.getElementById("refreshBtn"),
  saveAddrBtn: document.getElementById("saveAddrBtn"),
  account: document.getElementById("account"),
  chain: document.getElementById("chain"),
  stateBadge: document.getElementById("stateBadge"),
  entryFee: document.getElementById("entryFee"),
  winner: document.getElementById("winner"),
  requestId: document.getElementById("requestId"),
  players: document.getElementById("players"),
  enterBtn: document.getElementById("enterBtn"),
  startBtn: document.getElementById("startBtn"),
  endBtn: document.getElementById("endBtn"),
  ownerHint: document.getElementById("ownerHint"),
  log: document.getElementById("log"),
  debugLog: document.getElementById("debugLog"),
  copyDebugBtn: document.getElementById("copyDebugBtn"),
  txExplorerLink: document.getElementById("txExplorerLink"),
};

let provider = null;
let signer = null;
let contract = null;
let userAddress = null;
let chainIdBigInt = null;

/** 最近一次链上上下文，供调试区与复制 */
let debugSnapshot = {};

function explorerTxUrl(chainId, txHash) {
  if (!txHash) return null;
  const id = Number(chainId);
  const map = {
    1: "https://etherscan.io/tx/",
    11155111: "https://sepolia.etherscan.io/tx/",
    17000: "https://holesky.etherscan.io/tx/",
    421614: "https://sepolia.arbiscan.io/tx/",
    84532: "https://sepolia.basescan.org/tx/",
    80002: "https://amoy.polygonscan.com/tx/",
    137: "https://polygonscan.com/tx/",
    42161: "https://arbiscan.io/tx/",
    8453: "https://basescan.org/tx/",
    10: "https://optimistic.etherscan.io/tx/",
    11155420: "https://sepolia-optimism.etherscan.io/tx/",
  };
  const base = map[id];
  return base ? base + txHash : null;
}

/** 从钱包 / ethers 错误对象中尽量取出 revert data */
function extractErrorData(e) {
  if (!e) return null;
  if (typeof e.data === "string" && e.data.startsWith("0x")) return e.data;
  if (e.data && typeof e.data === "string" && e.data.startsWith("0x"))
    return e.data;
  if (e.error?.data && typeof e.error.data === "string") return e.error.data;
  if (e.info?.error?.data && typeof e.info.error.data === "string")
    return e.info.error.data;
  if (e.body?.error?.data && typeof e.body.error.data === "string")
    return e.body.error.data;
  return null;
}

/** 解码标准 Error(string) */
function tryDecodeErrorString(data) {
  if (!data || data.length < 10) return null;
  if (!data.startsWith("0x08c379a0")) return null;
  try {
    const reason = ethers.AbiCoder.defaultAbiCoder().decode(
      ["string"],
      "0x" + data.slice(10)
    )[0];
    return `Error(string): ${reason}`;
  } catch {
    return null;
  }
}

/** 解码 VRF Coordinator 自定义错误（按 selector 匹配 ErrorFragment） */
function tryDecodeVrfCustomError(data) {
  if (!VRF_ERROR_IFACE || !data || data.length < 10) return null;
  const selector = data.slice(0, 10);
  try {
    for (const frag of VRF_ERROR_IFACE.fragments) {
      if (frag.type !== "error") continue;
      if (frag.selector !== selector) continue;
      const decoded = VRF_ERROR_IFACE.decodeErrorResult(frag, data);
      const parts = [...decoded].map((a) =>
        a?.toString ? a.toString() : String(a)
      );
      return `${frag.name}(${parts.join(", ")})`;
    }
  } catch {
    return null;
  }
  return null;
}

function jsonSafeStringify(obj) {
  try {
    return JSON.stringify(
      obj,
      (_, v) => (typeof v === "bigint" ? v.toString() : v),
      2
    );
  } catch {
    return String(obj);
  }
}

/**
 * 将任意交易/调用错误格式化为多行说明，便于复制与排查
 */
function formatTxError(e) {
  const lines = [];
  const code = e?.code ?? "";
  const shortMessage = e?.shortMessage ?? "";
  const message = e?.message ?? "";
  if (code) lines.push(`code: ${code}`);
  if (shortMessage) lines.push(`shortMessage: ${shortMessage}`);
  if (message && message !== shortMessage) lines.push(`message: ${message}`);

  if (code === "ACTION_REJECTED" || e?.code === 4001) {
    lines.push("说明: 用户在钱包中拒绝了签名/交易。");
    return lines.join("\n");
  }

  if (e?.revert != null) {
    lines.push(`ethers 已解码 revert:\n${jsonSafeStringify(e.revert)}`);
  }

  const data = extractErrorData(e);
  if (data) {
    lines.push(`data: ${data}`);
    const errStr = tryDecodeErrorString(data);
    if (errStr) lines.push(`解码 Error(string): ${errStr}`);
    const vrfErr = tryDecodeVrfCustomError(data);
    if (vrfErr) lines.push(`解码 VRF Coordinator 自定义错误: ${vrfErr}`);
    if (!e?.revert && !errStr && !vrfErr && data.length >= 10) {
      lines.push(
        "提示: 无法解码时可复制 data 到 Sepolia Etherscan 的 Input 解码器或 4byte.directory 查询 selector。"
      );
    }
  } else {
    lines.push("data: (无 — 部分环境不返回 revert data，请到区块浏览器查看模拟/交易详情)");
  }

  if (e?.reason) lines.push(`reason: ${e.reason}`);
  return lines.join("\n");
}

function mergeDebug(partial) {
  debugSnapshot = {
    ...debugSnapshot,
    ...partial,
    updatedAt: new Date().toISOString(),
  };
  renderDebug();
}

function renderDebug() {
  if (!els.debugLog) return;
  const text = JSON.stringify(debugSnapshot, null, 2);
  els.debugLog.textContent =
    text.length > 2 ? text : "（尚无调试数据：连接钱包并操作后将显示链上上下文与错误详情）";
}

function setTxExplorerLink(txHash) {
  if (!els.txExplorerLink) return;
  const url = chainIdBigInt != null ? explorerTxUrl(chainIdBigInt, txHash) : null;
  if (url) {
    els.txExplorerLink.href = url;
    els.txExplorerLink.style.display = "inline";
    els.txExplorerLink.textContent = "在区块浏览器打开上一笔交易";
  } else {
    els.txExplorerLink.style.display = "none";
    els.txExplorerLink.removeAttribute("href");
  }
}

function log(msg, type = "") {
  els.log.textContent = msg;
  els.log.className = "log" + (type ? " " + type : "");
}

/** 主日志一行摘要 + 调试区完整错误 */
function logError(summary, e, extraContext = {}) {
  log(summary, "error");
  const detail = formatTxError(e);
  mergeDebug({
    lastError: detail,
    ...extraContext,
  });
  console.error(e);
}

function logSuccess(msg) {
  log(msg, "ok");
}

/** 从 localStorage 恢复上次填的合约地址，避免每次重输 */
function loadSavedAddress() {
  const saved = localStorage.getItem("fairchain_lottery_address");
  if (saved) els.contractInput.value = saved;
}

function saveAddress() {
  const addr = els.contractInput.value.trim();
  if (addr) localStorage.setItem("fairchain_lottery_address", addr);
  logSuccess("已保存合约地址到浏览器本地存储。");
  mergeDebug({ contractAddress: addr });
}

/**
 * 连接 MetaMask（或其它注入 window.ethereum 的钱包）
 * Provider：只读，可调用 view 函数；Signer：可签名发交易。
 */
async function connectWallet() {
  if (!window.ethereum) {
    log("未检测到钱包：请安装 MetaMask 或使用内置 Web3 的浏览器。", "error");
    return;
  }
  provider = new ethers.BrowserProvider(window.ethereum);
  await provider.send("eth_requestAccounts", []);
  signer = await provider.getSigner();
  userAddress = await signer.getAddress();
  els.account.textContent = userAddress;

  const net = await provider.getNetwork();
  chainIdBigInt = net.chainId;
  els.chain.textContent = `${net.name} (chainId ${net.chainId})`;

  mergeDebug({
    chainId: net.chainId.toString(),
    account: userAddress,
    contractAddress: els.contractInput.value.trim() || undefined,
  });

  await attachContract();
  await refreshState();
}

/**
 * 用「当前地址 + ABI」构造 Contract 实例。
 * 读操作用 contract 即可；写操作需 connect(signer)。
 */
async function attachContract() {
  const addr = els.contractInput.value.trim();
  if (!ethers.isAddress(addr)) {
    log("请输入合法的合约地址（0x 开头 42 字符）。", "error");
    contract = null;
    return;
  }
  contract = new ethers.Contract(addr, LOTTERY_ABI, provider);
  mergeDebug({ contractAddress: addr });
}

async function refreshState() {
  if (!contract || !userAddress) {
    log("请先连接钱包并填写正确合约地址。");
    return;
  }

  try {
    const addr = els.contractInput.value.trim();
    contract = new ethers.Contract(addr, LOTTERY_ABI, provider);
    const cRead = contract.connect(provider);

    const [state, fee, winner, reqId, players] = await Promise.all([
      cRead.lotteryState(),
      cRead.entryFee(),
      cRead.recentWinner(),
      cRead.latestRequestId(),
      cRead.getPlayers(),
    ]);

    let owner;
    try {
      owner = await cRead.owner();
    } catch {
      owner = null;
    }

    els.stateBadge.className = "badge";
    if (Number(state) === STATE.OPEN) {
      els.stateBadge.textContent = "OPEN · 开放投注";
      els.stateBadge.classList.add("badge-open");
    } else if (Number(state) === STATE.CALCULATING) {
      els.stateBadge.textContent = "CALCULATING · 等待随机数";
      els.stateBadge.classList.add("badge-calc");
    } else {
      els.stateBadge.textContent = "CLOSED · 未开奖/已结束";
      els.stateBadge.classList.add("badge-closed");
    }

    els.entryFee.textContent = `${ethers.formatEther(fee)} ETH`;
    els.winner.textContent = winner === ethers.ZeroAddress ? "—" : winner;
    els.requestId.textContent = reqId.toString();

    els.players.innerHTML = "";
    if (players.length === 0) {
      els.players.innerHTML = "<li>暂无参与者</li>";
    } else {
      players.forEach((p, i) => {
        const li = document.createElement("li");
        li.textContent = `${i + 1}. ${p}`;
        els.players.appendChild(li);
      });
    }

    const isOwner =
      owner !== null && owner.toLowerCase() === userAddress.toLowerCase();
    if (owner === null) {
      els.ownerHint.textContent =
        "未能读取 owner（请确认网络与合约地址正确；本合约应继承带 owner() 的基类）。";
      els.startBtn.disabled = true;
      els.endBtn.disabled = true;
    } else {
      els.ownerHint.textContent = isOwner
        ? "你是合约 owner，可进行开始/结束抽奖。"
        : "当前账户不是 owner，仅能参与投注（需开奖开放时）。";
      els.startBtn.disabled = !isOwner;
      els.endBtn.disabled = !isOwner;
    }

    const open = Number(state) === STATE.OPEN;
    els.enterBtn.disabled = !open;

    mergeDebug({
      lotteryState: Number(state),
      playersCount: players.length,
      entryFeeWei: fee.toString(),
      latestRequestId: reqId.toString(),
      lastError: null,
    });

    logSuccess("状态已刷新。");
  } catch (e) {
    logError("读取失败（见下方调试详情）", e, { action: "refreshState" });
  }
}

/**
 * enter() 是 payable：必须附带至少 entryFee 的 ETH。
 */
async function enterLottery() {
  if (!signer || !contract) {
    log("请先连接钱包。");
    return;
  }
  const addr = els.contractInput.value.trim();
  const c = contract.connect(signer);
  try {
    const fee = await contract.entryFee();
    mergeDebug({
      action: "enter",
      contractAddress: addr,
      valueWei: fee.toString(),
      valueEth: ethers.formatEther(fee),
    });
    log("正在模拟 enter（staticCall）…");
    await c.enter.staticCall({ value: fee });
    log("模拟通过，请在钱包中确认 enter 交易…");
    const tx = await c.enter({ value: fee });
    mergeDebug({ lastTxHash: tx.hash });
    setTxExplorerLink(tx.hash);
    log(`已提交：${tx.hash}，等待确认…`);
    await tx.wait();
    logSuccess("参与成功，交易已确认。");
    await refreshState();
  } catch (e) {
    logError("enter 失败（见下方调试详情）", e, {
      action: "enter",
      contractAddress: addr,
    });
  }
}

async function startLottery() {
  if (!signer || !contract) return;
  const addr = els.contractInput.value.trim();
  const c = contract.connect(signer);
  try {
    mergeDebug({ action: "startLottery", contractAddress: addr });
    log("正在模拟 startLottery（staticCall）…");
    await c.startLottery.staticCall();
    log("模拟通过，请在钱包中确认 startLottery…");
    const tx = await c.startLottery();
    mergeDebug({ lastTxHash: tx.hash });
    setTxExplorerLink(tx.hash);
    await tx.wait();
    logSuccess("抽奖已开始。");
    await refreshState();
  } catch (e) {
    logError("startLottery 失败（见下方调试详情）", e, {
      action: "startLottery",
      contractAddress: addr,
    });
  }
}

async function endLottery() {
  if (!signer || !contract) return;
  const addr = els.contractInput.value.trim();
  const c = contract.connect(signer);
  try {
    mergeDebug({
      action: "endLottery",
      contractAddress: addr,
      note:
        "第一笔交易仅调用 requestRandomWords；中奖者与清池在 Coordinator 回调 fulfillRandomWords 时完成。",
    });
    log("正在模拟 endLottery（staticCall，含 VRF 请求校验）…");
    await c.endLottery.staticCall();
    log("模拟通过，请在钱包中确认 endLottery（将请求 VRF）…");
    const tx = await c.endLottery();
    mergeDebug({ lastTxHash: tx.hash });
    setTxExplorerLink(tx.hash);
    log(
      `已提交请求交易：${tx.hash}。等待确认后，VRF 会另发回调交易完成开奖；请稍后点「刷新」并可在浏览器查看回调是否成功。`,
      "ok"
    );
    els.log.className = "log ok";
    await tx.wait();
    await refreshState();
  } catch (e) {
    logError("endLottery 失败（见下方调试详情）", e, {
      action: "endLottery",
      contractAddress: addr,
    });
  }
}

function copyDebugToClipboard() {
  const text = JSON.stringify(debugSnapshot, null, 2);
  const full =
    text +
    "\n\n--- formatTxError 原文（若有 lastError 已含在 JSON）---\n" +
    (debugSnapshot.lastError || "");
  navigator.clipboard.writeText(full).then(
    () => logSuccess("已复制调试信息到剪贴板。"),
    () => log("复制失败，请手动选择调试区文本。", "error")
  );
}

function wireEvents() {
  els.connectBtn.addEventListener("click", connectWallet);
  els.refreshBtn.addEventListener("click", refreshState);
  els.saveAddrBtn.addEventListener("click", saveAddress);
  els.enterBtn.addEventListener("click", enterLottery);
  els.startBtn.addEventListener("click", startLottery);
  els.endBtn.addEventListener("click", endLottery);
  if (els.copyDebugBtn) {
    els.copyDebugBtn.addEventListener("click", copyDebugToClipboard);
  }

  els.contractInput.addEventListener("change", async () => {
    if (provider) await attachContract();
  });

  if (window.ethereum) {
    window.ethereum.on("accountsChanged", () => {
      userAddress = null;
      els.account.textContent = "—";
      log("账户已切换，请重新连接。");
    });
    window.ethereum.on("chainChanged", () => {
      window.location.reload();
    });
  }
}

loadSavedAddress();
renderDebug();
wireEvents();
log("填写合约地址后连接钱包；建议在本地或测试网使用。");
