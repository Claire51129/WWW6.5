const CONFIG = {
  // Fill with deployed address to enable on-chain mode.
  contractAddress: "",
  abi: [
    "function addCandidate(string memory _candidate)",
    "function vote(string memory _candidate)",
    "function getCandidates() view returns (string[] memory)",
    "function getVotes(string memory _candidate) view returns (uint256)",
  ],
};

const STORAGE_KEY = "uplinkira-day3-voting";

const el = {
  mode: document.getElementById("mode"),
  status: document.getElementById("status"),
  candidateInput: document.getElementById("candidateInput"),
  voteInput: document.getElementById("voteInput"),
  board: document.getElementById("board"),
  connectBtn: document.getElementById("connectBtn"),
  addBtn: document.getElementById("addBtn"),
  voteBtn: document.getElementById("voteBtn"),
  refreshBtn: document.getElementById("refreshBtn"),
};

const state = {
  isDemo: !/^0x[a-fA-F0-9]{40}$/.test(CONFIG.contractAddress),
  provider: null,
  signer: null,
  contract: null,
  demo: JSON.parse(localStorage.getItem(STORAGE_KEY) || "{\"candidates\":[],\"votes\":{}}"),
};

function setStatus(message) {
  el.status.textContent = message;
}

function persistDemo() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.demo));
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

    if (!state.isDemo) {
      state.contract = new ethers.Contract(CONFIG.contractAddress, CONFIG.abi, state.signer);
    }

    el.addBtn.disabled = false;
    el.voteBtn.disabled = false;
    el.refreshBtn.disabled = false;
    setStatus("Wallet connected.");
    await refreshBoard();
  } catch (error) {
    setStatus(`Connect failed: ${error.message || error}`);
  }
}

async function addCandidate() {
  const candidate = el.candidateInput.value.trim();
  if (!candidate) {
    setStatus("Candidate name is required.");
    return;
  }

  el.addBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (state.demo.candidates.includes(candidate)) {
        throw new Error("Candidate already exists.");
      }
      state.demo.candidates.push(candidate);
      state.demo.votes[candidate] = 0;
      persistDemo();
    } else {
      const tx = await state.contract.addCandidate(candidate);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.candidateInput.value = "";
    setStatus("Candidate added.");
    await refreshBoard();
  } catch (error) {
    setStatus(`Add failed: ${error.message || error}`);
  } finally {
    el.addBtn.disabled = false;
  }
}

async function vote() {
  const candidate = el.voteInput.value.trim();
  if (!candidate) {
    setStatus("Candidate name is required for vote.");
    return;
  }

  el.voteBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (!state.demo.candidates.includes(candidate)) {
        throw new Error("Unknown candidate.");
      }
      state.demo.votes[candidate] += 1;
      persistDemo();
    } else {
      const tx = await state.contract.vote(candidate);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    el.voteInput.value = "";
    setStatus("Vote recorded.");
    await refreshBoard();
  } catch (error) {
    setStatus(`Vote failed: ${error.message || error}`);
  } finally {
    el.voteBtn.disabled = false;
  }
}

async function refreshBoard() {
  try {
    let names = [];
    let counts = [];

    if (state.isDemo) {
      names = [...state.demo.candidates];
      counts = names.map((name) => state.demo.votes[name] || 0);
    } else {
      names = await state.contract.getCandidates();
      counts = [];
      for (const name of names) {
        const count = await state.contract.getVotes(name);
        counts.push(Number(count));
      }
    }

    el.board.innerHTML = "";
    if (!names.length) {
      const li = document.createElement("li");
      li.textContent = "No candidates yet.";
      el.board.appendChild(li);
      return;
    }

    names.forEach((name, idx) => {
      const li = document.createElement("li");
      li.textContent = `${name}: ${counts[idx]} vote(s)`;
      el.board.appendChild(li);
    });
  } catch (error) {
    setStatus(`Refresh failed: ${error.message || error}`);
  }
}

function init() {
  el.mode.textContent = state.isDemo ? "Mode: Demo (local simulation)" : "Mode: On-chain";
  el.connectBtn.addEventListener("click", connectWallet);
  el.addBtn.addEventListener("click", addCandidate);
  el.voteBtn.addEventListener("click", vote);
  el.refreshBtn.addEventListener("click", refreshBoard);
  refreshBoard();
}

init();
