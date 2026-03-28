// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * Day 17 - 逻辑合约 V1
 * 
 * 包含订阅管理的基础功能：
 * - 添加套餐
 * - 订阅套餐
 * - 查询订阅状态
 * 
 * ⚠️ 重要：此合约不包含构造函数（或构造函数必须为空）
 * 因为 delegatecall 不会执行逻辑合约的构造函数！
 */
contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    
    // 事件
    event PlanAdded(uint8 indexed planId, uint256 price, uint256 duration);
    event Subscribed(address indexed user, uint8 indexed planId, uint256 expiry);
    event SubscriptionExtended(address indexed user, uint256 newExpiry);
    
    // 权限修饰符（owner 从代理合约读取）
    modifier onlyOwner() {
        require(msg.sender == owner, "SubscriptionLogicV1: caller is not the owner");
        _;
    }
    
    /**
     * 添加套餐
     * @param planId 套餐ID（如1=基础版，2=高级版）
     * @param price 价格（wei）
     * @param duration 订阅时长（秒）
     */
    function addPlan(uint8 planId, uint256 price, uint256 duration) external onlyOwner {
        require(planId > 0, "SubscriptionLogicV1: planId must be > 0");
        require(price > 0, "SubscriptionLogicV1: price must be > 0");
        require(duration > 0, "SubscriptionLogicV1: duration must be > 0");
        require(planPrices[planId] == 0, "SubscriptionLogicV1: plan already exists");
        
        planPrices[planId] = price;
        planDuration[planId] = duration;
        
        emit PlanAdded(planId, price, duration);
    }
    
    /**
     * 订阅套餐
     * @param planId 套餐ID
     */
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "SubscriptionLogicV1: invalid plan");
        require(msg.value >= planPrices[planId], "SubscriptionLogicV1: insufficient payment");
        
        Subscription storage s = subscriptions[msg.sender];
        
        // 如果已有订阅且未过期，则延长；否则新建
        if (block.timestamp < s.expiry && !s.paused) {
            // 延长现有订阅
            s.expiry += planDuration[planId];
            emit SubscriptionExtended(msg.sender, s.expiry);
        } else {
            // 新订阅或已过期
            s.planId = planId;
            s.expiry = block.timestamp + planDuration[planId];
            s.paused = false;
            emit Subscribed(msg.sender, planId, s.expiry);
        }
        
        // 退款多余金额
        uint256 excess = msg.value - planPrices[planId];
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }
    
    /**
     * 检查订阅是否有效
     * @param user 用户地址
     * @return 是否有效订阅
     */
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return s.expiry > block.timestamp && !s.paused;
    }
    
    /**
     * 获取订阅过期时间
     * @param user 用户地址
     * @return 过期时间戳（0表示无订阅）
     */
    function getExpiry(address user) external view returns (uint256) {
        return subscriptions[user].expiry;
    }
    
    /**
     * 获取套餐价格
     * @param planId 套餐ID
     * @return 价格（wei）
     */
    function getPlanPrice(uint8 planId) external view returns (uint256) {
        return planPrices[planId];
    }
    
    /**
     * 获取套餐时长
     * @param planId 套餐ID
     * @return 时长（秒）
     */
    function getPlanDuration(uint8 planId) external view returns (uint256) {
        return planDuration[planId];
    }
    
    /**
     * 获取合约版本
     */
    function getVersion() external pure returns (uint256) {
        return 1;
    }
}