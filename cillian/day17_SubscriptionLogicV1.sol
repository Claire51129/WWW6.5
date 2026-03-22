// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * @title SubscriptionLogicV1
 * @dev 订阅系统的逻辑实现合约（V1版本）。
 * 重要：这个合约本身不存储钱和数据，它只是一个“工具箱”。
 * 当存储合约（Proxy）调用这里时，它会修改存储合约里的变量。
 */
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    /**
     * @notice 添加或修改订阅套餐
     * @param planId 套餐的唯一标识（如 1 代表月卡）
     * @param price 套餐价格（单位：Wei）
     * @param duration 套餐持续的秒数（如 30 * 24 * 3600）
     */
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        // 注意：这里修改的 planPrices 实际上是存储合约里的映射
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    /**
     * @notice 用户通过支付以太坊订阅套餐
     * @dev 包含“续费”和“新购”两种逻辑
     * @param planId 用户想要购买的套餐等级
     */
    function subscribe(uint8 planId) external payable {
        // 1. 检查套餐是否真实有效
        require(planPrices[planId] > 0, "Invalid plan");
        // 2. 检查用户支付的钱够不够
        require(msg.value >= planPrices[planId], "Insufficient payment");

        // 3. 获取该用户的订阅记录（指向存储合约中的数据）
        Subscription storage s = subscriptions[msg.sender];
        
        // 4. 计算到期时间
        if (block.timestamp < s.expiry) {
            // 如果用户还没过期，就在原有的到期时间上往后续（续费逻辑）
            s.expiry += planDuration[planId];
        } else {
            // 如果已经过期，就从当前时间开始计算（新购逻辑）
            s.expiry = block.timestamp + planDuration[planId];
        }

        // 5. 更新状态变量
        s.planId = planId;
        s.paused = false;
    }

    /**
     * @notice 查询用户当前的订阅状态
     * @param user 要查询的用户地址
     * @return bool 返回 true 表示会员有效，false 表示已过期或已暂停
     */
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        // 逻辑：当前时间小于到期时间，且没有处于暂停状态
        return (block.timestamp < s.expiry && !s.paused);
    }
}