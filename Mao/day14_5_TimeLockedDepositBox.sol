// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//你可以存储一个秘密，但在特定时间过去之前你无法检索它。
import "./day14_2_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;

    constructor(address initialOwner, uint256 lockDuration) BaseDepositBox(initialOwner) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
  
  //金库所有者只有在解锁时间过去后可以查看
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }
 
   //对于前端和显示目的很有用。
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }
 
 //对于在你的 UI 中创建倒计时、计时器或可视化进度条非常有用。倒计时助手
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}
