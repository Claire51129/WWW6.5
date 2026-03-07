# Day3 VotingSystem MVP

## What this day covers

1. Array for candidate list
2. Mapping for vote counts
3. Write functions: `addCandidate`, `vote`
4. Read functions: `getCandidates`, `getVotes`

## Files

1. `src/day3_votingsystem.sol`: Solidity contract
2. `ui/dapp-demo/`: minimal interaction demo

## Run demo

```bash
python -m http.server 5173
```

Open:

```txt
http://localhost:5173/uplinkira/day3-votingsystem/ui/dapp-demo/
```

## Demo mode vs on-chain mode

1. Default is Demo mode (localStorage).
2. To use real chain mode, set `contractAddress` in `ui/dapp-demo/app.js`.
