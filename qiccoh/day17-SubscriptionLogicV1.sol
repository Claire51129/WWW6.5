 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";
/** 第一个逻辑合约
- 添加新套餐
- 用户订阅
- 检查活跃状态
**/

contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // 允许所有者（或任何调用它的人）注册一个新的订阅套餐 套餐名、价格、持续时间
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;//母类中已经定义过planPrices
        planDuration[planId] = duration;
    }
// 让用户通过发送 ETH 来订阅特定的套餐external payable ？？
    function subscribe(uint8 planId) external payable {
        
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");
// 核查套餐是否存在、钱包钱够不够
        Subscription storage s = subscriptions[msg.sender];//获取调用者的订阅记录
    //    之前是否到期
        if (block.timestamp < s.expiry) {
            // 没有到期，续上
            s.expiry += planDuration[planId];
        } else {
// 到期了，现在时间+套餐时间
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;//storage 永久存储用户选择的套餐
        s.paused = false;//取消暂停订阅
    }
// 检查用户的订阅当前是否活跃
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];//临时的看下得了，不改变状态
        return (block.timestamp < s.expiry && !s.paused);
        //双重1、时间 2、没有被关闭
    }
}

