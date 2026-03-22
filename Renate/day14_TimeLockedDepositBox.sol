// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本：兼容0.8.x系列
import "./day14_BaseDepositBox.sol";
// 导入BaseDepositBox抽象基合约，继承其核心存款盒功能

// 时间锁定版存款盒合约（继承BaseDepositBox）
// 核心扩展：新增时间锁机制，锁定期内禁止读取私密信息
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime; // 解锁时间戳（Unix时间）：仅到达该时间可读取秘密

    // 构造函数：初始化时间锁（参数lockDuration为锁定时长，单位：秒）
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration; // 解锁时间 = 当前区块时间 + 锁定时长
    }

    // 时间锁修饰器：仅解锁后可调用被修饰函数
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still locked"); // 校验当前时间已过解锁时间
        _;
    }

    // 获取存款盒类型（重写父合约函数，pure函数无状态读写）
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked"; // 返回类型标识：时间锁定版存款盒
    }

    // 获取私密信息（重写父合约函数，需同时满足：所有者权限 + 时间解锁）
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret(); // 调用父合约方法获取私密信息
    }

    // 获取解锁时间戳（view函数仅读取状态）
    function getUnlockTime() external view returns(uint256) {
        return unlockTime;
    }

    // 获取剩余锁定时长（单位：秒，已解锁则返回0）
    function getRemainingLockTime() external view returns(uint256) {
        if(block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}