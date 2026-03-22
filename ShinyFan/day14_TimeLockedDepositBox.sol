// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;//新增时间点

    constructor(address initialOwner, uint256 lockDuration) BaseDepositBox(initialOwner) {//构造函数（初始主人地址，锁多久时长）
        unlockTime = block.timestamp + lockDuration;
    }

    //修饰符 检索时间是否超过已经解锁时间
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    //重写：必须是所有者+时间到了 才能看秘密
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }

    //查看解锁时间
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    //查看还剩多久解锁
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}