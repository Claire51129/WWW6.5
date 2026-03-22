// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    
    address public logicContract; // 当前逻辑合约的地址
    address public owner;         // 合约拥有者
    
    // 订阅信息的数据结构
    struct Subscription {
        uint8 planId;      // 订阅计划编号（比如1=基础版，2=高级版）
        uint256 expiry;    // 订阅到期时间（时间戳）
        bool paused;       // 是否被暂停
    }
    
    // 每个用户地址 → 对应他的订阅信息
    mapping(address => Subscription) public subscriptions;
    
    // 计划编号 → 对应价格（单位：wei）
    mapping(uint8 => uint256) public planPrices;
    
    // 计划编号 → 对应持续时间（单位：秒）
    mapping(uint8 => uint256) public planDuration;
}
