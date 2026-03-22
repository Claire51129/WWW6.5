 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import {SubscriptionStorageLayout} from "./day17_SubscriptionStorageLayout.sol";
import "./day17_SubscriptionStorageLayout.sol";

//第一个逻辑合约：允许用户添加新套餐，订阅套餐，检查活跃状态
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    //允许所有者注册一个新的订阅套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        //每个 planId 代表一个唯一的套餐
        planPrices[planId] = price;//套餐价格
        planDuration[planId] = duration;//套餐时间
    }
    //让用户通过发送 ETH 来订阅特定的套餐
    //- 它简单且节省 gas,它在一个函数中支持新用户和现有用户,它会自动“恢复”已暂停的订阅（对于 V2 等功能很有用）
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");
        //按照订阅是否到期，来设置套餐的到期时间
        Subscription storage s = subscriptions[msg.sender];
        //如果用户还有剩余时间 (`block.timestamp < s.expiry`)：将新的持续时间添加到当前到期时间（比如上月到期，进入下月）
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
        //如果订阅已过期：将到期时间重置为当前时间 + 持续时间,相当于重新订阅
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false;
    }
    //让任何人检查用户的订阅当前是否活跃
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}

