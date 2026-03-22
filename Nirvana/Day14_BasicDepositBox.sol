// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Day14_BaseDepositBox.sol";

contract Day14_BasicDepositBox is Day14_BaseDepositBox {
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}
