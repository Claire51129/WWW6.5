// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Day 17 - 订阅管理系统存储布局
 * 
 * 这是所有合约共享的存储布局基类。
 * 代理合约和逻辑合约都必须继承此合约，确保存储槽位完全一致！
 * 
 * ⚠️ 警告：任何对存储变量的修改都会导致升级失败或数据损坏！
 */
contract SubscriptionStorageLayout {
    
    // 槽位 0: 逻辑合约地址（代理合约使用）
    address public logicContract;
    
    // 槽位 1: 管理员地址
    address public owner;
    
    // 槽位 2-4: 订阅数据结构
    struct Subscription {
        uint8 planId;       // 套餐ID (1字节)
        uint256 expiry;     // 过期时间戳 (32字节) - 会导致结构体占两个槽位
        bool paused;        // 是否暂停 (1字节)
    }
    
    // 槽位 5 (keccak256 后): 用户订阅映射
    mapping(address => Subscription) public subscriptions;
    
    // 槽位 6 (keccak256 后): 套餐价格
    mapping(uint8 => uint256) public planPrices;
    
    // 槽位 7 (keccak256 后): 套餐时长（秒）
    mapping(uint8 => uint256) public planDuration;
    
    // 槽位 8: 版本号（用于追踪）
    uint256 public version;
}