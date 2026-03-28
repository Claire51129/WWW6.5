// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * Day 17 - 逻辑合约 V2
 * 
 * V2 新增功能：
 * - 暂停/恢复账户
 * - 获取完整的订阅详情
 * - 更详细的订阅状态检查
 * 
 * 升级后数据完全保留！
 */
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    
    // 继承 V1 的事件
    event PlanAdded(uint8 indexed planId, uint256 price, uint256 duration);
    event Subscribed(address indexed user, uint8 indexed planId, uint256 expiry);
    event SubscriptionExtended(address indexed user, uint256 newExpiry);
    
    // V2 新增事件
    event AccountPaused(address indexed user, address indexed by);
    event AccountResumed(address indexed user, address indexed by);
    
    // 权限修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "SubscriptionLogicV2: caller is not the owner");
        _;
    }
    
    modifier onlySelfOrOwner(address user) {
        require(
            msg.sender == user || msg.sender == owner,
            "SubscriptionLogicV2: caller is not the user or owner"
        );
        _;
    }
    
    // ============ V1 功能（完全兼容）============
    
    function addPlan(uint8 planId, uint256 price, uint256 duration) external onlyOwner {
        require(planId > 0, "SubscriptionLogicV2: planId must be > 0");
        require(price > 0, "SubscriptionLogicV2: price must be > 0");
        require(duration > 0, "SubscriptionLogicV2: duration must be > 0");
        require(planPrices[planId] == 0, "SubscriptionLogicV2: plan already exists");
        
        planPrices[planId] = price;
        planDuration[planId] = duration;
        
        emit PlanAdded(planId, price, duration);
    }
    
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "SubscriptionLogicV2: invalid plan");
        require(msg.value >= planPrices[planId], "SubscriptionLogicV2: insufficient payment");
        
        Subscription storage s = subscriptions[msg.sender];
        
        // 检查是否被暂停
        require(!s.paused || block.timestamp >= s.expiry, "SubscriptionLogicV2: account is paused");
        
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
            emit SubscriptionExtended(msg.sender, s.expiry);
        } else {
            s.planId = planId;
            s.expiry = block.timestamp + planDuration[planId];
            s.paused = false;
            emit Subscribed(msg.sender, planId, s.expiry);
        }
        
        uint256 excess = msg.value - planPrices[planId];
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }
    
    function isActive(address user) external view returns (bool) {
        Subscription storage s = subscriptions[user];
        return s.expiry > block.timestamp && !s.paused;
    }
    
    function getExpiry(address user) external view returns (uint256) {
        return subscriptions[user].expiry;
    }
    
    function getPlanPrice(uint8 planId) external view returns (uint256) {
        return planPrices[planId];
    }
    
    function getPlanDuration(uint8 planId) external view returns (uint256) {
        return planDuration[planId];
    }
    
    // ============ V2 新增功能 ============
    
    /**
     * 暂停账户
     * 只有用户自己或管理员可以操作
     */
    function pauseAccount(address user) external onlySelfOrOwner(user) {
        Subscription storage s = subscriptions[user];
        require(s.expiry > block.timestamp, "SubscriptionLogicV2: subscription expired");
        require(!s.paused, "SubscriptionLogicV2: already paused");
        
        s.paused = true;
        emit AccountPaused(user, msg.sender);
    }
    
    /**
     * 恢复账户
     * 只有用户自己或管理员可以操作
     */
    function resumeAccount(address user) external onlySelfOrOwner(user) {
        Subscription storage s = subscriptions[user];
        require(s.paused, "SubscriptionLogicV2: not paused");
        
        s.paused = false;
        emit AccountResumed(user, msg.sender);
    }
    
    /**
     * 检查账户是否被暂停
     */
    function isPaused(address user) external view returns (bool) {
        return subscriptions[user].paused;
    }
    
    /**
     * 获取完整的订阅详情
     * @return planId 套餐ID
     * @return expiry 过期时间
     * @return paused 是否暂停
     * @return active 是否有效
     * @return remainingDays 剩余天数
     */
    function getSubscriptionDetails(address user) 
        external 
        view 
        returns (
            uint8 planId,
            uint256 expiry,
            bool paused,
            bool active,
            uint256 remainingDays
        ) 
    {
        Subscription storage s = subscriptions[user];
        planId = s.planId;
        expiry = s.expiry;
        paused = s.paused;
        active = s.expiry > block.timestamp && !s.paused;
        
        if (s.expiry > block.timestamp) {
            remainingDays = (s.expiry - block.timestamp) / 1 days;
        } else {
            remainingDays = 0;
        }
    }
    
    /**
     * 获取订阅状态描述
     */
    function getSubscriptionStatus(address user) 
        external 
        view 
        returns (string memory) 
    {
        Subscription storage s = subscriptions[user];
        
        if (s.expiry == 0) {
            return "No subscription";
        }
        if (s.expiry <= block.timestamp) {
            return "Expired";
        }
        if (s.paused) {
            return "Paused";
        }
        return "Active";
    }
    
    /**
     * 获取合约版本
     */
    function getVersion() external pure returns (uint256) {
        return 2;
    }
}