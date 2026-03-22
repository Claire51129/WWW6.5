 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";
// 带有暂停/恢复功能
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
/***
- 添加或更新订阅套餐。
- 使用 `planId` 作为套餐的标识符。
- 存储它的成本和持续时间。
***/
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
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
// 上面同v1
// 手动暂停用户的账户
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
// 重新启用已暂停的订阅
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}

