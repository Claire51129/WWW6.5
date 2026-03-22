// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }
    
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");
        
        Subscription storage s = subscriptions[msg.sender];
        
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];  // 延长现有订阅
        } else {
            s.expiry = block.timestamp + planDuration[planId];  // 新订阅
        }
        
        s.planId = planId;
        s.paused = false;
    }
    
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}