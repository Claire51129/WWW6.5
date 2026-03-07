const CONFIG = {
  // 部署后替换为真实地址；为空则自动使用 Demo 模式。
  contractAddress: "",
  abi: [
    "function counter() view returns (uint256)",
    "function click()",
  ],
};

const DEMO_KEY = "uplinkira-day1-counter";

const el = {
  mode: document.getElementById("mode"),
  counter: document.getElementById("counter"),
  status: document.getElementById("status"),
  connectBtn: document.getElementById("connectBtn"),
  clickBtn: document.getElementById("clickBtn"),
};

const state = {
  isDemo: !/^0x[a-fA-F0-9]{40}$/.test(CONFIG.contractAddress),
  provider: null,
  signer: null,
  contract: null,
  demoValue: Number(localStorage.getItem(DEMO_KEY) || "0"),
};

function setStatus(msg) {
  el.status.textContent = msg;
}

async function readCounter() {
  if (state.isDemo) return state.demoValue;
  const value = await state.contract.counter();
  return Number(value);
}

async function refresh() {
  el.counter.textContent = String(await readCounter());
}

async function connectWallet() {
  if (!window.ethereum) {
    setStatus("未检测到 MetaMask。");
    return;
  }

  try {
    state.provider = new ethers.BrowserProvider(window.ethereum);
    await state.provider.send("eth_requestAccounts", []);
    state.signer = await state.provider.getSigner();

    if (!state.isDemo) {
      state.contract = new ethers.Contract(CONFIG.contractAddress, CONFIG.abi, state.signer);
    }

    el.clickBtn.disabled = false;
    setStatus("钱包已连接。");
    await refresh();
  } catch (error) {
    setStatus(`连接失败：${error.message || error}`);
  }
}

async function onClick() {
  el.clickBtn.disabled = true;
  try {
    if (state.isDemo) {
      state.demoValue += 1;
      localStorage.setItem(DEMO_KEY, String(state.demoValue));
    } else {
      const tx = await state.contract.click();
      setStatus(`交易已发送：${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    await refresh();
    setStatus("计数成功 +1");
  } catch (error) {
    setStatus(`操作失败：${error.message || error}`);
  } finally {
    el.clickBtn.disabled = false;
  }
}

function init() {
  el.mode.textContent = state.isDemo ? "模式：Demo（本地模拟）" : "模式：链上";
  el.connectBtn.addEventListener("click", connectWallet);
  el.clickBtn.addEventListener("click", onClick);
  refresh();
}

init();
