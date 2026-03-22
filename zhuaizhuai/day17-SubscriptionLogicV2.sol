// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

// 逻辑合约V2：升级版
// 比V1多了pauseAccount和resumeAccount两个功能
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    
    // 跟V1一样：添加订阅计划
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }
    
    // 跟V1一样：用户订阅
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
    
    // 跟V1一样：查询是否有效
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
    
    // 🆕 V2新增：暂停用户账户
    function pauseAccount(address user) external {
        subscriptions[user].paused = true; // 把用户的paused改成true
    }
    
    // 🆕 V2新增：恢复用户账户
    function resumeAccount(address user) external {
        subscriptions[user].paused = false; // 把用户的paused改成false
    }
}
