// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入存储布局合约
import "./day17-SubscriptionStorageLayout.sol";

// SubscriptionLogicV2 - 订阅逻辑合约 V2
// 这是 V1 的升级版本，新增了暂停订阅功能
// 展示了可升级合约模式如何添加新功能而不丢失数据
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    // V2 新增功能: 暂停/恢复订阅

    // 创建订阅计划（仅合约所有者）
    // planId: 计划 ID
    // price: 计划价格（wei）
    // duration: 订阅持续时间（秒）
    function createPlan(uint8 planId, uint256 price, uint256 duration) external {
        require(msg.sender == owner, "Only owner");
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 订阅计划
    // planId: 要订阅的计划 ID
    // 需要支付与计划价格相等的 ETH
    function subscribe(uint8 planId) external payable {
        // 验证计划存在
        require(planPrices[planId] > 0, "Plan does not exist");
        // 验证支付金额
        require(msg.value == planPrices[planId], "Incorrect ETH amount");

        // 创建订阅记录
        subscriptions[msg.sender] = Subscription({
            planId: planId,
            expiry: block.timestamp + planDuration[planId],
            paused: false
        });
    }

    // 暂停订阅（V2 新增功能）
    // 允许用户暂停自己的订阅，剩余时间会被保存
    // 暂停期间订阅不计时
    function pauseSubscription() external {
        Subscription storage sub = subscriptions[msg.sender];

        // 验证订阅未过期
        require(sub.expiry > block.timestamp, "Subscription expired");
        // 验证未处于暂停状态
        require(!sub.paused, "Already paused");

        // 标记为暂停状态
        sub.paused = true;

        // 计算并保存剩余时间（秒）
        // 将剩余时间存入 expiry 字段临时存储
        sub.expiry = sub.expiry - block.timestamp;
    }

    // 恢复订阅（V2 新增功能）
    // 用户恢复暂停的订阅，剩余时间会重新计算
    function resumeSubscription() external {
        Subscription storage sub = subscriptions[msg.sender];

        // 验证处于暂停状态
        require(sub.paused, "Not paused");

        // 取消暂停状态
        sub.paused = false;

        // 重新计算过期时间: 当前时间 + 之前保存的剩余时间
        sub.expiry = block.timestamp + sub.expiry;
    }

    // 检查用户是否处于有效订阅状态（V2 更新）
    // 考虑了暂停状态：暂停期间视为未订阅
    // user: 用户地址
    // 返回: true 表示订阅有效且未暂停，false 表示已过期、未订阅或已暂停
    function isSubscribed(address user) external view returns (bool) {
         Subscription memory sub = subscriptions[user];

         // 如果处于暂停状态，返回 false
         if (sub.paused) return false;

         // 检查是否未过期
         return sub.expiry > block.timestamp;
    }
}
