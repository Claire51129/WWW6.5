// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

// 订阅逻辑合约 V2 - 升级版业务逻辑
contract SubscriptionLogicV2 is SubscriptionStorageLayout {

    // 添加套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 订阅
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];

        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];  // 续费叠加
        } else {
            s.expiry = block.timestamp + planDuration[planId];  // 新订阅
        }

        s.planId = planId;
        s.paused = false;
    }

    // 检查订阅是否有效
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    //以下是 V2 新增的功能

    // 暂停用户订阅 - V1 里 paused 字段存在但没有函数能修改它，V2 补上了
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }

    // 恢复用户订阅 - 取消暂停，用户重新可以使用服务
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }

    // 查询订阅详情 - 一次性返回套餐 ID、到期时间、是否暂停
    // V1 只能通过 isActive 查一个 bool，V2 可以看到完整信息了
    function getSubscriptionDetails(address user) external view returns (uint8, uint256, bool) {
        Subscription storage s = subscriptions[user];
        return (s.planId, s.expiry, s.paused);
    }
}