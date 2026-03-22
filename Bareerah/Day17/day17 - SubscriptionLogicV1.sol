// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17 - SubscriptionStorageLayout.sol";

contract SubscriptionLoginV1 is SubscriptionStorageLayout{

    // 注册一个新的订阅套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 允许用户发送 ETH 来订阅特定的套餐
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscription[msg.sender];
        if(block.timestamp < s.expiry){
            s.expiry += planDuration[planId];
        }else{
            s.expiry = block.timestamp + planDuration[planId];
        }
        s.planId = planId;
        s.paused = false;
    }

    // 让任何人检查用户的订阅当前是否活跃
    // 场景：- 前端（显示订阅状态）、对高级功能进行门控访问、显示续订提示
    function isActive(address user) external view returns(bool){
        Subscription memory s = subscription[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}