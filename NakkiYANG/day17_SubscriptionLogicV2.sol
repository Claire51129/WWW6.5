// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day17_SubscriptionStorageLayout.sol";
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    // 继承V1的所有功能
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }
    
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");
        
        Subscription storage s = subscriptions[msg.sender];
        
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }
        
        s.planId = planId;
        s.paused = false;
    }
    
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
    
    // V2 新增功能
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
    
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
    
    // 获取订阅详情
    function getSubscriptionDetails(address user) external view returns (uint8, uint256, bool) {
        Subscription storage s = subscriptions[user];
        return (s.planId, s.expiry, s.paused);
    }
}