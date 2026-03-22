// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    // 添加订阅计划（管理员用）
    // 比如：addPlan(1, 0.01 ETH, 30天)
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;      // 设置这个计划的价格
        planDuration[planId] = duration; // 设置这个计划的持续时间
    }
    
    // 用户订阅
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");           // 检查计划是否存在
        require(msg.value >= planPrices[planId], "Insufficient payment"); // 检查付款够不够
        
        Subscription storage s = subscriptions[msg.sender]; // 找到这个用户的订阅记录
        
        // 判断用户是否还在订阅期内
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId]; // 还没过期→续费，在原来基础上加时间
        } else {
            s.expiry = block.timestamp + planDuration[planId]; // 已过期→重新开始计算
        }
        
        s.planId = planId; // 记录订阅的计划编号
        s.paused = false;  // 设置为未暂停
    }
    
    // 查询用户订阅是否有效
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user]; // 读取用户订阅信息
        return (block.timestamp < s.expiry && !s.paused);
        // 没过期 并且 没暂停 → 有效✅
    }
}
