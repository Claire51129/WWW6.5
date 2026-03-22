// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入存储布局合约
import "./day17-SubscriptionStorageLayout.sol";

// SubscriptionLogicV1 - 订阅逻辑合约 V1
// 这是可升级合约架构中的逻辑实现合约
// 使用代理模式（Proxy Pattern）实现合约升级
// 注意: 逻辑合约本身不存储数据，数据存储在代理合约中
contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    // 初始化函数
    // 在真实场景中，代理合约部署后会调用此函数来设置初始状态
    // 这里假设 owner 由代理合约构造函数设置
    function initialize() external {
        // 可用于设置初始状态
        // 在实际应用中，我们使用 initialize 函数代替构造函数
    }

    // 创建订阅计划（仅合约所有者）
    // planId: 计划 ID（如 1, 2, 3 表示不同级别的套餐）
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
        // 验证计划存在（价格大于 0）
        require(planPrices[planId] > 0, "Plan does not exist");
        // 验证支付的 ETH 金额正确
        require(msg.value == planPrices[planId], "Incorrect ETH amount");

        // 创建订阅记录
        subscriptions[msg.sender] = Subscription({
            planId: planId,
            expiry: block.timestamp + planDuration[planId],  // 计算过期时间
            paused: false
        });
    }

    // 检查用户是否处于有效订阅状态
    // user: 用户地址
    // 返回: true 表示订阅有效，false 表示已过期或未订阅
    function isSubscribed(address user) external view returns (bool) {
        return subscriptions[user].expiry > block.timestamp;
    }
}
