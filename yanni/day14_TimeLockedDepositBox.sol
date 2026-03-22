// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//从 BaseDepositBox 导入共享基础逻辑
import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    //private时间戳
    uint256 private unlockTime;

    //构造函数lockDuration，以秒为单位
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration;
    }

    //解锁时间
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    //返回金库类型
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    //重写了 BaseDepositBox 中的常规函数 getSecret()
    //增加两个检查：onlyOwner和timelock
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }


    //何时解锁
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    //剩余秒数
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}
