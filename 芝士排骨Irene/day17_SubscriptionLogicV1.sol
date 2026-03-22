// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

// 订阅逻辑合约 V1 - 第一版业务逻辑
contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // 添加套餐 - 设置某个套餐的价格和时长
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;       // 设置套餐价格
        planDuration[planId] = duration;  // 设置套餐时长（秒）
    }

    // 订阅 - 用户付 ETH 购买套餐
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");            // 套餐必须存在（价格不为 0）
        require(msg.value >= planPrices[planId], "Insufficient payment"); // 付的钱必须够

        // 用 storage 引用用户的订阅信息，修改会直接写入链上
        Subscription storage s = subscriptions[msg.sender];

        // 判断用户是否还在有效期内
        if (block.timestamp < s.expiry) {
            // 还没过期 → 在现有到期时间上延长（续费叠加）
            // 例如：还剩 10 天到期，买了 30 天月卡 → 到期时间变成 40 天后
            s.expiry += planDuration[planId];
        } else {
            // 已过期或从未订阅 → 从当前时间开始算新的有效期
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;  // 记录当前套餐类型
        s.paused = false;   // 订阅后自动取消暂停状态
    }

    // 检查用户订阅是否有效
    // 两个条件同时满足：没过期 且 没有被暂停
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}