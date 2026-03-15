// SPDX-License-Identifier: MIT
//TimeLockedDepositBox

pragma solidity ^0.8.0; 

import "./Day14_BaseDepositBox.sol";  // 导入母合约

contract TimeLockedDepositBox is BaseDepositBox{  // 继承母合约，时间锁存款箱

    uint256 private unlockTime;  // 私有变量：解锁时间戳（到什么时间才能打开）

    constructor(address initialOwner, uint256 lockDuration) 
    BaseDepositBox(initialOwner)  // 先调用母合约构造函数
{
    unlockTime = block.timestamp + lockDuration;
}

    modifier timeUnlocked(){  // 自定义修饰符：检查是否已解锁
        require(block.timestamp >= unlockTime, "Box is still locked");  // 现在时间 >= 解锁时间？
        _;  // 已解锁，继续执行
    }

    function getBoxType() external pure override returns (string memory) {  // 返回盒子类型
        return "TimeLocked";  // 这个盒子是时间锁款
    }

    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        // override: 重写母合约的函数
        // onlyOwner: 必须主人（来自母合约）
        // timeUnlocked: 必须已解锁（本合约的修饰符）
        // 两个修饰符同时用，两个条件都要满足
        return super.getSecret();  // 调用母合约的getSecret()拿秘密
        // super: 调用母合约的版本
    }

    function getUnlockTime() external view returns(uint256){  // 查看解锁时间
        return unlockTime;  // 返回解锁时间戳
    }

    function getRemainingLockTime() external view returns(uint256){  // 查看还剩多久解锁
        if(block.timestamp >= unlockTime) return 0;  // 已解锁，返回0
        return unlockTime - block.timestamp;  // 解锁时间 - 现在 = 剩余秒数
    }
}   