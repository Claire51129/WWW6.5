# Day4 AuctionHouse MVP

## What this day covers

1. Constructor-based initialization
2. Conditional guards with `require`
3. Time checks with `block.timestamp`
4. Bid flow and winner state

## Files

1. `src/day4_auctionhouse.sol`: Solidity contract
2. `ui/dapp-demo/`: minimal interaction demo

## Run demo

```bash
python -m http.server 5173
```

Open:

```txt
http://localhost:5173/uplinkira/day4-auctionhouse/ui/dapp-demo/
```

## Demo mode vs on-chain mode

1. Default is Demo mode (local state simulation).
2. For chain mode, deploy contract first and set `contractAddress` in `ui/dapp-demo/app.js`.
