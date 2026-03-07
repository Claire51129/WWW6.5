# Web3 Learning Notebook (Women Cohort 6.5)

This folder is the main learning notebook for:

1. The Web3Compass Solidity video series: `https://www.youtube.com/watch?v=MCz9RrQfpj8&list=PL3gCWoU4wyU35lrmNNrQpk_-UIlmmco6M&index=27`
2. Herstory China Women Cohort `6.5` collaborative learning activity.

Technical statement: This repository converts course videos into executable contract exercises and explainable engineering artifacts.  
Plain analogy: It is a study lab where every lecture becomes a small working machine you can touch and test.

------

## What Lives Here

1. `day1-clickcounter/`: Day 1 contract + UI demo.
2. `day2-savemyname/`: Day 2 contract + UI demo.
3. `day3-votingsystem/`: Day 3 contract + UI demo.
4. `day4-auctionhouse/`: Day 4 contract + UI demo.
5. `day5-adminonly/`: Day 5 contract + UI demo.
6. `baseline/`: reusable toolchain baseline for all 30 days.
7. `../Note/script/`: transcript materials and extraction notes.
8. `../Note/note.md`: consolidated theory notes.

Technical statement: Day folders are organized as learning modules with source and minimal interaction demos.  
Plain analogy: Each day is one chapter with both textbook pages and a small experiment kit.

---

## Web3 Stack Positioning (Why These Days Matter)

Technical statement: A standard Web3 path is `UI -> wallet -> RPC -> EVM execution -> storage -> read back`.  
Plain analogy: It works like `screen -> signature card -> service counter -> rule engine -> public ledger -> status check`.

Technical statement: Solidity contracts are the trust anchor because state transitions are validated by consensus.  
Plain analogy: Rules are enforced by a shared public court, not by one app server admin.

Technical statement: Day1-Day5 forms a compact progression from basic state mutation to structured data, collection logic, time constraints, and role-based access control.  
Plain analogy: You start with a simple button, then profile forms, then vote tables, then auction deadlines, and finally admin permissions.

---

## State Machine Overview

### Day1 `ClickCounter`

Technical statement: The full state is one storage variable `counter`.  
Plain analogy: One permanent number on a public scoreboard.

Technical statement: Transition is `click(): counter := counter + 1`.  
Plain analogy: Press one button and the score goes up by exactly one.

### Day2 `SaveMyName`

Technical statement: The full state is a tuple `(name, bio)`.  
Plain analogy: One profile card with two text fields.

Technical statement: `add()` writes state, `retrieve()` reads state without mutation.  
Plain analogy: One function edits the card, the other only reads it through glass.

### Day3 `VotingSystem`

Technical statement: The state combines candidate array + vote-count mapping.  
Plain analogy: It is a scoreboard with both a name list and a count table.

Technical statement: Core transitions are `addCandidate` and `vote`.  
Plain analogy: One action registers players, the other gives points.

### Day4 `AuctionHouse`

Technical statement: The state includes owner, item, end time, bid table, highest bid, and highest bidder.  
Plain analogy: It is an auction room logbook with clock and leaderboard.

Technical statement: Core transitions are `bid` and `endAuction` under time and role guards.  
Plain analogy: You can place bids before the bell; only the organizer can close the room.

### Day5 `AdminOnly`

Technical statement: The state includes owner, treasury amount, and allowance mapping per address.  
Plain analogy: It is a vault with a manager plus approved withdrawal slips.

Technical statement: Core transitions are `addTreasure`, `approveWithdrawal`, `withdrawTreasure`, and `transferOwnership`.  
Plain analogy: The manager fills the vault, grants permits, users withdraw by permit, and manager role can be handed over.

---

## Day1 Deep Technical Walkthrough

File: `day1-clickcounter/src/day1_clickcounter.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ClickCounter {
    uint256 public counter;

    function click() public {
        counter++;
    }
}
```

### Line-by-Line

Technical statement: `SPDX-License-Identifier` provides machine-readable license metadata.  
Plain analogy: It is the legal label on a product box.

Technical statement: `pragma solidity ^0.8.20` pins allowed compiler range for semantic consistency.  
Plain analogy: It is the approved firmware version list for this device.

Technical statement: `contract ClickCounter` defines code namespace and storage scope on-chain.  
Plain analogy: It creates one locked cabinet with a dedicated nameplate.

Technical statement: `uint256 public counter` allocates persistent storage and auto-generates getter `counter()`.  
Plain analogy: It installs a permanent odometer plus a public viewing window.

Technical statement: `function click() public` exposes a write endpoint callable by external accounts.  
Plain analogy: It adds a public button anyone can press.

Technical statement: `counter++` compiles to storage read-modify-write and consumes gas.  
Plain analogy: It opens the ledger, edits one number, then notarizes the new value.

### Parameter and State Flow

Technical statement: UI call to `click()` becomes a signed transaction in wallet.  
Plain analogy: You submit a signed request form before anything changes.

Technical statement: EVM executes bytecode, updates storage, and commits result in a block.  
Plain analogy: The clerk processes your form and writes the new value into the official archive.

Technical statement: UI reads `counter()` again to render post-transaction state.  
Plain analogy: The screen refreshes by checking the archive after approval.

---

## Day2 Deep Technical Walkthrough

File: `day2-savemyname/src/day2_savemyname.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SaveMyName {
    string public name;
    string public bio;

    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }

    function retrieve() public view returns (string memory, string memory) {
        return (name, bio);
    }
}
```

### Line-by-Line

Technical statement: `string public name` stores dynamic UTF-8-like byte data in contract storage and adds getter `name()`.  
Plain analogy: It is one permanent text field on a profile card.

Technical statement: `string public bio` adds a second persistent text field.  
Plain analogy: It is the “about me” line under the name.

Technical statement: `add(string memory _name, string memory _bio)` receives temporary in-memory parameters.  
Plain analogy: Inputs first land on scratch paper before filing.

Technical statement: `name = _name` copies from memory to storage and incurs state-write cost.  
Plain analogy: You copy from sticky note into official registry.

Technical statement: `bio = _bio` performs the same commit for the second field.  
Plain analogy: You file the second line into the same registry card.

Technical statement: `retrieve() public view returns (...)` guarantees no storage mutation and returns tuple data.  
Plain analogy: It is a read-only inquiry desk handing back both profile fields.

### Key Variable Transmission

Technical statement: User input values are ABI-encoded by client library and sent with transaction payload for `add`.  
Plain analogy: Form fields are packed into a standard envelope so the clerk can decode them.

Technical statement: EVM decodes calldata, maps values to `_name` and `_bio`, then writes to storage.  
Plain analogy: The clerk opens envelope, reads both lines, and updates the filing cabinet.

Technical statement: `retrieve()` returns ABI-encoded `(name, bio)` for client-side decoding and rendering.  
Plain analogy: The desk prints a two-field receipt and the app shows it on screen.

---

## Day3–Day5 Implementation Summary

### Day3 `VotingSystem` (implemented)

Technical statement: Focus shifts to arrays, mappings, and voting-style counting logic.  
Plain analogy: You move from one profile card to a list of candidates plus a vote tally table.

Implemented components:

1. Candidate list array.
2. Mapping from candidate identifier to vote count.
3. Add candidate function.
4. Vote function.
5. Read functions for names and vote counts.

### Day4 `AuctionHouse` (implemented)

Technical statement: Auction-style contract introduces `if/else`, `require`, `block.timestamp`, constructor setup, and per-user bid mapping.  
Plain analogy: It becomes a timed auction room with admission rules and bid records per bidder.

Implemented components:

1. Owner and auction item initialization in constructor.
2. Time-bound bidding checks.
3. `bid` validation rules.
4. Auction closing function.
5. Winner query function.

### Day5 `AdminOnly` (implemented)

Technical statement: Access control is formalized with `modifier`, `msg.sender`, owner-only operations, and withdrawal allowances via mappings.  
Plain analogy: It is a treasure vault where owner keys and approved withdrawal slips control who can take what.

Implemented components:

1. `onlyOwner` modifier.
2. Treasury amount state.
3. Allowance mapping per address.
4. Owner approval function.
5. Withdraw flow with role-dependent checks.

---

## Why This Sequence Is Meaningful

Technical statement: Day1->Day5 forms a progressive path: scalar state -> structured text state -> collections -> time + conditional control -> role-based access control.  
Plain analogy: It is learning numbers, then forms, then tables, then deadlines, then permissions.

Technical statement: This progression mirrors real protocol development: model state, enforce transitions, constrain actors, then expose safe read paths.  
Plain analogy: Build the ledger, define legal edits, decide who can edit, and always provide transparent lookup.

---

## Practical Usage Route

1. Read the day transcript extraction in `../Note/script/`.
2. Build the contract in `src/`.
3. Run minimal UI demo in `ui/dapp-demo/`.
4. Explain each function as state transition before writing next day.

Technical statement: Repeating this loop develops both coding ability and protocol reasoning ability.  
Plain analogy: You are training both your hands and your engineering judgment at the same time.
