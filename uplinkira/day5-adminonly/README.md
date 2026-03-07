# Day5 AdminOnly MVP

## What this day covers

1. Owner identity via `msg.sender`
2. Access control with `onlyOwner` modifier
3. Allowance mapping for non-owner withdrawals
4. Owner transfer and guarded treasury operations

## Files

1. `src/day5_adminonly.sol`: Solidity contract
2. `ui/dapp-demo/`: minimal interaction demo

## Run demo

```bash
python -m http.server 5173
```

Open:

```txt
http://localhost:5173/uplinkira/day5-adminonly/ui/dapp-demo/
```

## Demo mode vs on-chain mode

1. Default is Demo mode (local state simulation).
2. For chain mode, deploy contract first and set `contractAddress` in `ui/dapp-demo/app.js`.
