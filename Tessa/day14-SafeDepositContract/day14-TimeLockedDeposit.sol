//时间锁保险箱
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import {BaseDepositBox} from "./day14-BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox{

    uint256 private unlockTime;    //解锁时间（新变量）
    constructor(uint256 lockDuration){
        unlockTime = block.timestamp + lockDuration;    //当前时间 + 锁定时间 = 解锁时间
    }

    modifier timeUnlocked(){    // 时间锁修饰器：时间没到不能打开
        require(block.timestamp >= unlockTime, "Box is still locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
}
    // 覆盖getSecret
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {    //要求：必须是owner，必须解锁
        return super.getSecret();
} 

    // 获取解锁时间
    function getUnlockTime() external view returns(uint256){
        return unlockTime;    // 返回
    }

    // 获取剩余时间
    function getRemainingLockTime() external view returns(uint256){
        if(block.timestamp >= unlockTime) return 0;    //如时间到，返回0
        return unlockTime - block.timestamp;    //否则
    }



    
}

// 时间锁：block.timestamp
// modifier组合：onlyOwner+timeUnlocked
// override：覆盖母函数