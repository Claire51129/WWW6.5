 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    //注册新的订阅套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    //发送eth订阅特定套餐
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");
        //从 subscriptions 映射中获取调用者的订阅记录
        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            //延长订阅
            s.expiry += planDuration[planId];  // s.expiry = s.expiry + planDuration[planId]
        } else {
            //新订阅
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false; //取消暂停订阅
    }

    //订阅当前是否活跃
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}

