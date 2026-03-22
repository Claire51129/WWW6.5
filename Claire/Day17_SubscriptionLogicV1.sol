// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本

import "./Day17_SubscriptionStorageLayout.sol";
// 导入存储布局合约
// 继承后，获得所有存储变量：
// - logicContract（逻辑合约地址）
// - owner（所有者地址）
// - subscriptions（用户订阅数据）
// - planPrices（套餐价格）
// - planDuration（套餐时长）

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
// 定义一个合约，叫"订阅逻辑V1"
// 继承 SubscriptionStorageLayout，所以可以直接访问所有存储变量
// 注意：这个合约不定义新的状态变量，避免存储冲突

    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
    // 函数：添加/修改套餐
    // uint8 planId：套餐ID（0-255）
    // uint256 price：套餐价格（单位：wei）
    // uint256 duration：套餐有效期（单位：秒）
    // external：只能外部调用
        
        planPrices[planId] = price;
        // 存储套餐价格
        
        planDuration[planId] = duration;
        // 存储套餐有效期时长
    }

    function subscribe(uint8 planId) external payable {
    // 函数：订阅套餐
    // uint8 planId：要订阅的套餐ID
    // external payable：外部调用，可以附带ETH
        
        require(planPrices[planId] > 0, "Invalid plan");
        // 检查：套餐存在（价格大于0）
        
        require(msg.value >= planPrices[planId], "Insufficient payment");
        // 检查：支付的ETH足够（可以多付，但不会找零）

        Subscription storage s = subscriptions[msg.sender];
        // 获取当前用户的订阅信息（storage引用，直接操作链上数据）
        // storage表示直接引用链上存储，修改会永久保存

        if (block.timestamp < s.expiry) {
        // 如果当前时间 < 到期时间（订阅还没过期）
            s.expiry += planDuration[planId];
            // 在原有到期时间上增加新套餐的时长（续费）
            // 例如：原来12月1日到期，买30天套餐 → 12月31日到期
        } else {
        // 如果订阅已过期
            s.expiry = block.timestamp + planDuration[planId];
            // 从现在开始计算新的到期时间
            // 例如：已经过期，今天买30天 → 30天后到期
        }

        s.planId = planId;
        // 更新用户当前的套餐ID
        
        s.paused = false;
        // 确保订阅是激活状态（如果之前暂停了，自动恢复）
    }

    function isActive(address user) external view returns (bool) {
    // 函数：检查用户的订阅是否有效
    // address user：要检查的用户地址
    // external view：只读函数，不修改链上数据
    // returns (bool)：返回true=有效，false=无效
        
        Subscription memory s = subscriptions[user];
        // 取出用户的订阅信息（memory表示复制到内存，临时使用）
        
        return (block.timestamp < s.expiry && !s.paused);
        // 两个条件都满足才算有效：
        // 1. 当前时间 < 到期时间（没过期）
        // 2. 没有被暂停（!s.paused 表示未暂停）
    }
}