 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

// 定义了我们逻辑合约的第二个版本
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
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

    // 前端应用程序或其他智能合约用来检查是否有权使用高级功能
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    // 手动暂停用户的账户
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
        
    //重新启用已暂停的订阅
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}

