const CONFIG = {
  // 部署后替换为真实地址；为空则自动 Demo。
  contractAddress: "",
  abi: [
    "function add(string memory _name, string memory _bio)",
    "function retrieve() view returns (string memory, string memory)",
  ],
};

const DEMO_KEY = "uplinkira-day2-profile";

const el = {
  mode: document.getElementById("mode"),
  status: document.getElementById("status"),
  nameInput: document.getElementById("nameInput"),
  bioInput: document.getElementById("bioInput"),
  nameOut: document.getElementById("nameOut"),
  bioOut: document.getElementById("bioOut"),
  connectBtn: document.getElementById("connectBtn"),
  addBtn: document.getElementById("addBtn"),
  retrieveBtn: document.getElementById("retrieveBtn"),
};

const state = {
  isDemo: !/^0x[a-fA-F0-9]{40}$/.test(CONFIG.contractAddress),
  provider: null,
  signer: null,
  contract: null,
  profile: JSON.parse(localStorage.getItem(DEMO_KEY) || "{\"name\":\"\",\"bio\":\"\"}"),
};

function setStatus(msg) {
  el.status.textContent = msg;
}

function renderProfile(name, bio) {
  el.nameOut.textContent = name || "-";
  el.bioOut.textContent = bio || "-";
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

    el.addBtn.disabled = false;
    el.retrieveBtn.disabled = false;
    setStatus("钱包已连接。");
  } catch (error) {
    setStatus(`连接失败：${error.message || error}`);
  }
}

async function addProfile() {
  const name = el.nameInput.value.trim();
  const bio = el.bioInput.value.trim();

  if (!name || !bio) {
    setStatus("Name 和 Bio 都不能为空。");
    return;
  }

  el.addBtn.disabled = true;
  try {
    if (state.isDemo) {
      state.profile = { name, bio };
      localStorage.setItem(DEMO_KEY, JSON.stringify(state.profile));
    } else {
      const tx = await state.contract.add(name, bio);
      setStatus(`交易已发送：${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }
    setStatus("保存成功。");
    await retrieveProfile();
  } catch (error) {
    setStatus(`保存失败：${error.message || error}`);
  } finally {
    el.addBtn.disabled = false;
  }
}

async function retrieveProfile() {
  el.retrieveBtn.disabled = true;
  try {
    if (state.isDemo) {
      renderProfile(state.profile.name, state.profile.bio);
    } else {
      const [name, bio] = await state.contract.retrieve();
      renderProfile(name, bio);
    }
    setStatus("读取成功。");
  } catch (error) {
    setStatus(`读取失败：${error.message || error}`);
  } finally {
    el.retrieveBtn.disabled = false;
  }
}

function init() {
  el.mode.textContent = state.isDemo ? "模式：Demo（本地模拟）" : "模式：链上";
  el.connectBtn.addEventListener("click", connectWallet);
  el.addBtn.addEventListener("click", addProfile);
  el.retrieveBtn.addEventListener("click", retrieveProfile);
  renderProfile(state.profile.name, state.profile.bio);
}

init();
