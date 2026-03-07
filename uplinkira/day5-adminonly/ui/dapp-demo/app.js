const CONFIG = {
  // Fill with deployed address to enable on-chain mode.
  contractAddress: "",
  abi: [
    "function owner() view returns (address)",
    "function treasureAmount() view returns (uint256)",
    "function withdrawalAllowance(address user) view returns (uint256)",
    "function addTreasure(uint256 amount)",
    "function approveWithdrawal(address recipient, uint256 amount)",
    "function withdrawTreasure(uint256 amount)",
    "function transferOwnership(address newOwner)",
  ],
};

const STORAGE_KEY = "uplinkira-day5-adminonly";

const el = {
  mode: document.getElementById("mode"),
  status: document.getElementById("status"),
  owner: document.getElementById("owner"),
  account: document.getElementById("account"),
  treasure: document.getElementById("treasure"),
  allowance: document.getElementById("allowance"),
  addInput: document.getElementById("addInput"),
  recipientInput: document.getElementById("recipientInput"),
  approveInput: document.getElementById("approveInput"),
  withdrawInput: document.getElementById("withdrawInput"),
  newOwnerInput: document.getElementById("newOwnerInput"),
  connectBtn: document.getElementById("connectBtn"),
  refreshBtn: document.getElementById("refreshBtn"),
  addBtn: document.getElementById("addBtn"),
  approveBtn: document.getElementById("approveBtn"),
  withdrawBtn: document.getElementById("withdrawBtn"),
  transferBtn: document.getElementById("transferBtn"),
};

function makeInitialDemo() {
  return {
    owner: "",
    treasureAmount: 0,
    withdrawalAllowance: {},
  };
}

const state = {
  isDemo: !/^0x[a-fA-F0-9]{40}$/.test(CONFIG.contractAddress),
  provider: null,
  signer: null,
  account: "",
  contract: null,
  demo: JSON.parse(localStorage.getItem(STORAGE_KEY) || "null") || makeInitialDemo(),
};

function setStatus(message) {
  el.status.textContent = message;
}

function persistDemo() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.demo));
}

function shortAddress(address) {
  if (!address) return "-";
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function normalizeAddress(address) {
  return address.toLowerCase();
}

function parsePositiveInt(raw) {
  const n = Number(raw);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.floor(n);
}

async function connectWallet() {
  if (!window.ethereum) {
    setStatus("MetaMask not detected.");
    return;
  }

  try {
    state.provider = new ethers.BrowserProvider(window.ethereum);
    await state.provider.send("eth_requestAccounts", []);
    state.signer = await state.provider.getSigner();
    state.account = await state.signer.getAddress();

    if (!state.isDemo) {
      state.contract = new ethers.Contract(CONFIG.contractAddress, CONFIG.abi, state.signer);
    } else if (!state.demo.owner) {
      state.demo.owner = state.account;
      persistDemo();
    }

    el.refreshBtn.disabled = false;
    el.addBtn.disabled = false;
    el.approveBtn.disabled = false;
    el.withdrawBtn.disabled = false;
    el.transferBtn.disabled = false;
    setStatus("Wallet connected.");
    await refresh();
  } catch (error) {
    setStatus(`Connect failed: ${error.message || error}`);
  }
}

async function addTreasure() {
  const amount = parsePositiveInt(el.addInput.value);
  if (!amount) {
    setStatus("Add amount must be greater than 0.");
    return;
  }

  el.addBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (normalizeAddress(state.account) !== normalizeAddress(state.demo.owner)) {
        throw new Error("Only owner can add treasure.");
      }
      state.demo.treasureAmount += amount;
      persistDemo();
    } else {
      const tx = await state.contract.addTreasure(amount);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.addInput.value = "";
    setStatus("Treasure added.");
    await refresh();
  } catch (error) {
    setStatus(`Add failed: ${error.message || error}`);
  } finally {
    el.addBtn.disabled = false;
  }
}

async function approveWithdrawal() {
  const recipient = el.recipientInput.value.trim();
  const amount = parsePositiveInt(el.approveInput.value);
  if (!recipient || !/^0x[a-fA-F0-9]{40}$/.test(recipient)) {
    setStatus("Recipient must be a valid address.");
    return;
  }
  if (!amount) {
    setStatus("Approval amount must be greater than 0.");
    return;
  }

  el.approveBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (normalizeAddress(state.account) !== normalizeAddress(state.demo.owner)) {
        throw new Error("Only owner can approve withdrawal.");
      }
      if (amount > state.demo.treasureAmount) {
        throw new Error("Not enough treasure available.");
      }
      state.demo.withdrawalAllowance[normalizeAddress(recipient)] = amount;
      persistDemo();
    } else {
      const tx = await state.contract.approveWithdrawal(recipient, amount);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.recipientInput.value = "";
    el.approveInput.value = "";
    setStatus("Allowance approved.");
    await refresh();
  } catch (error) {
    setStatus(`Approve failed: ${error.message || error}`);
  } finally {
    el.approveBtn.disabled = false;
  }
}

async function withdrawTreasure() {
  const amount = parsePositiveInt(el.withdrawInput.value);
  if (!amount) {
    setStatus("Withdraw amount must be greater than 0.");
    return;
  }

  el.withdrawBtn.disabled = true;
  try {
    if (state.isDemo) {
      const me = normalizeAddress(state.account);
      const owner = normalizeAddress(state.demo.owner);

      if (me === owner) {
        if (amount > state.demo.treasureAmount) throw new Error("Not enough treasure.");
        state.demo.treasureAmount -= amount;
      } else {
        const allowance = state.demo.withdrawalAllowance[me] || 0;
        if (amount > allowance) throw new Error("Amount exceeds allowance.");
        if (amount > state.demo.treasureAmount) throw new Error("Not enough treasure.");
        state.demo.withdrawalAllowance[me] = allowance - amount;
        state.demo.treasureAmount -= amount;
      }
      persistDemo();
    } else {
      const tx = await state.contract.withdrawTreasure(amount);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.withdrawInput.value = "";
    setStatus("Withdraw successful.");
    await refresh();
  } catch (error) {
    setStatus(`Withdraw failed: ${error.message || error}`);
  } finally {
    el.withdrawBtn.disabled = false;
  }
}

async function transferOwnership() {
  const newOwner = el.newOwnerInput.value.trim();
  if (!/^0x[a-fA-F0-9]{40}$/.test(newOwner)) {
    setStatus("New owner must be a valid address.");
    return;
  }

  el.transferBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (normalizeAddress(state.account) !== normalizeAddress(state.demo.owner)) {
        throw new Error("Only owner can transfer ownership.");
      }
      state.demo.owner = newOwner;
      persistDemo();
    } else {
      const tx = await state.contract.transferOwnership(newOwner);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.newOwnerInput.value = "";
    setStatus("Ownership transferred.");
    await refresh();
  } catch (error) {
    setStatus(`Transfer failed: ${error.message || error}`);
  } finally {
    el.transferBtn.disabled = false;
  }
}

async function refresh() {
  try {
    let owner;
    let treasure;
    let allowance;

    if (state.isDemo) {
      owner = state.demo.owner;
      treasure = state.demo.treasureAmount;
      allowance = state.demo.withdrawalAllowance[normalizeAddress(state.account)] || 0;
    } else {
      owner = await state.contract.owner();
      treasure = Number(await state.contract.treasureAmount());
      allowance = Number(await state.contract.withdrawalAllowance(state.account));
    }

    el.owner.textContent = shortAddress(owner);
    el.account.textContent = shortAddress(state.account);
    el.treasure.textContent = String(treasure);
    el.allowance.textContent = String(allowance);
  } catch (error) {
    setStatus(`Refresh failed: ${error.message || error}`);
  }
}

function init() {
  el.mode.textContent = state.isDemo ? "Mode: Demo (local simulation)" : "Mode: On-chain";
  el.connectBtn.addEventListener("click", connectWallet);
  el.refreshBtn.addEventListener("click", refresh);
  el.addBtn.addEventListener("click", addTreasure);
  el.approveBtn.addEventListener("click", approveWithdrawal);
  el.withdrawBtn.addEventListener("click", withdrawTreasure);
  el.transferBtn.addEventListener("click", transferOwnership);
}

init();
