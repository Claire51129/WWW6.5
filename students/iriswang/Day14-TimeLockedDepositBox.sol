// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day14-BasicDepositBox.sol";

contract TimeLockedDepositBox is BasicDepositBox {
    uint256 public lockDuration;
    uint256 public unlockTime;

    constructor(string memory _metadata, uint256 _lockDuration) BasicDepositBox(_metadata) {
        lockDuration = _lockDuration;
        unlockTime = block.timestamp + _lockDuration;
    }

    function getSecret() external view override onlyOwner returns (string memory) {
        require(block.timestamp >= unlockTime, "Box is still locked");
        // 直接调用 internal 函数，避免 super 问题
        return _getSecret();
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
}
