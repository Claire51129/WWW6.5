// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day14-BasicDepositBox.sol";

contract PremiumDepositBox is BasicDepositBox {
    constructor(string memory _metadata) BasicDepositBox(_metadata) {}

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
}
