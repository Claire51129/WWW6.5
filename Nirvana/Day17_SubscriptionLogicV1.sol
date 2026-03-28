 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day17_SubscriptionStorageLayout.sol";

contract Day17_SubscriptionLogicV1 is Day17_SubscriptionStorageLayout {
    
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price; // Allow updating existing plans
        planDuration[planId] = duration; 
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");// Check if the plan exists
        require(msg.value >= planPrices[planId], "Insufficient payment"); // Check if the user sends enough ETH

        Subscription storage s = subscriptions[msg.sender]; 
        if (block.timestamp < s.expiry) { // If the orginial subscription is still active
            s.expiry += planDuration[planId]; // Extend the subscription duration
        } else {
            s.expiry = block.timestamp + planDuration[planId]; // New subscription
        }

        s.planId = planId; //Record the new subscription
        s.paused = false; // Cancel the original suspension of subscription
    }

    function isActive(address user) external view returns (bool) { 
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}

