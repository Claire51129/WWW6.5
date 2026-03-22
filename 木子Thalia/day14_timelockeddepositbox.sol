// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_basedepositbox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;

    constructor(uint256 lockDuration) {
        // 解锁时间 = 当前时间 + 持续时间
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        // 检查：当前区块时间是否已经超过或等于解锁时间
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    function getBoxType() external pure override returns(string memory) {
        return "TimeLocked";
    }

    function getSecret() public view override onlyOwner timeUnlocked returns(string memory) {
        return super.getSecret();
    }

    // 返回具体的解锁时间戳
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    // 返回剩余秒数
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}
