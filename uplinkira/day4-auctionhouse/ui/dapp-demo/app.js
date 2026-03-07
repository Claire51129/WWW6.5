const CONFIG = {
  // Fill with deployed address to enable on-chain mode.
  contractAddress: "",
  abi: [
    "function item() view returns (string)",
    "function owner() view returns (address)",
    "function auctionEndTime() view returns (uint256)",
    "function ended() view returns (bool)",
    "function highestBid() view returns (uint256)",
    "function highestBidder() view returns (address)",
    "function bid(uint256 _amount)",
    "function endAuction()",
  ],
};

const STORAGE_KEY = "uplinkira-day4-auction";

const el = {
  mode: document.getElementById("mode"),
  status: document.getElementById("status"),
  item: document.getElementById("item"),
  owner: document.getElementById("owner"),
  highestBid: document.getElementById("highestBid"),
  highestBidder: document.getElementById("highestBidder"),
  timeLeft: document.getElementById("timeLeft"),
  ended: document.getElementById("ended"),
  amountInput: document.getElementById("amountInput"),
  connectBtn: document.getElementById("connectBtn"),
  bidBtn: document.getElementById("bidBtn"),
  endBtn: document.getElementById("endBtn"),
  refreshBtn: document.getElementById("refreshBtn"),
};

function makeInitialDemo() {
  const now = Math.floor(Date.now() / 1000);
  return {
    item: "Demo Vintage Camera",
    owner: "",
    auctionEndTime: now + 3600,
    ended: false,
    highestBid: 0,
    highestBidder: "",
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

function shortAddress(address) {
  if (!address) return "-";
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function persistDemo() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.demo));
}

function getTimeLeftText(endTime, ended) {
  if (ended) return "Auction ended";
  const now = Math.floor(Date.now() / 1000);
  const secondsLeft = endTime - now;
  if (secondsLeft <= 0) return "0s (can end now)";
  return `${secondsLeft}s`;
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

    el.bidBtn.disabled = false;
    el.endBtn.disabled = false;
    el.refreshBtn.disabled = false;
    setStatus("Wallet connected.");
    await refresh();
  } catch (error) {
    setStatus(`Connect failed: ${error.message || error}`);
  }
}

async function placeBid() {
  const amount = Number(el.amountInput.value);
  if (!Number.isFinite(amount) || amount <= 0) {
    setStatus("Bid amount must be greater than 0.");
    return;
  }

  el.bidBtn.disabled = true;
  try {
    if (state.isDemo) {
      const now = Math.floor(Date.now() / 1000);
      if (state.demo.ended) throw new Error("Auction already ended.");
      if (now >= state.demo.auctionEndTime) throw new Error("Auction time is over.");
      if (amount <= state.demo.highestBid) throw new Error("Bid must be greater than highest bid.");

      state.demo.highestBid = amount;
      state.demo.highestBidder = state.account;
      persistDemo();
    } else {
      const tx = await state.contract.bid(amount);
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    setStatus("Bid placed.");
    el.amountInput.value = "";
    await refresh();
  } catch (error) {
    setStatus(`Bid failed: ${error.message || error}`);
  } finally {
    el.bidBtn.disabled = false;
  }
}

async function endAuction() {
  el.endBtn.disabled = true;
  try {
    if (state.isDemo) {
      if (!state.account || state.account.toLowerCase() !== state.demo.owner.toLowerCase()) {
        throw new Error("Only owner can end auction.");
      }
      if (state.demo.ended) throw new Error("Auction already ended.");
      const now = Math.floor(Date.now() / 1000);
      if (now < state.demo.auctionEndTime) throw new Error("Auction is still active.");

      state.demo.ended = true;
      persistDemo();
    } else {
      const tx = await state.contract.endAuction();
      setStatus(`Tx sent: ${tx.hash.slice(0, 10)}...`);
      await tx.wait();
    }

    setStatus("Auction ended.");
    await refresh();
  } catch (error) {
    setStatus(`End failed: ${error.message || error}`);
  } finally {
    el.endBtn.disabled = false;
  }
}

async function refresh() {
  try {
    if (state.isDemo) {
      el.item.textContent = state.demo.item;
      el.owner.textContent = shortAddress(state.demo.owner);
      el.highestBid.textContent = String(state.demo.highestBid);
      el.highestBidder.textContent = shortAddress(state.demo.highestBidder);
      el.ended.textContent = String(state.demo.ended);
      el.timeLeft.textContent = getTimeLeftText(state.demo.auctionEndTime, state.demo.ended);
      return;
    }

    const [item, owner, auctionEndTime, ended, highestBid, highestBidder] = await Promise.all([
      state.contract.item(),
      state.contract.owner(),
      state.contract.auctionEndTime(),
      state.contract.ended(),
      state.contract.highestBid(),
      state.contract.highestBidder(),
    ]);

    el.item.textContent = item;
    el.owner.textContent = shortAddress(owner);
    el.highestBid.textContent = String(Number(highestBid));
    el.highestBidder.textContent = shortAddress(highestBidder);
    el.ended.textContent = String(ended);
    el.timeLeft.textContent = getTimeLeftText(Number(auctionEndTime), ended);
  } catch (error) {
    setStatus(`Refresh failed: ${error.message || error}`);
  }
}

function init() {
  el.mode.textContent = state.isDemo ? "Mode: Demo (local simulation)" : "Mode: On-chain";
  el.connectBtn.addEventListener("click", connectWallet);
  el.bidBtn.addEventListener("click", placeBid);
  el.endBtn.addEventListener("click", endAuction);
  el.refreshBtn.addEventListener("click", refresh);
  refresh();
}

init();
