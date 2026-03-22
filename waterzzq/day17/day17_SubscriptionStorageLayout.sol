// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 共享存储布局：代理和逻辑合约都用这个「存档格式」
contract SubscriptionStorageLayout {
    // 逻辑合约地址：代理用来知道要把调用转发给谁
    address public logicContract;
    // 合约所有者：只有他能升级逻辑合约
    address public owner;

    // 订阅信息：每个用户的「存档」
    struct Subscription {
        uint8 planId;      // 订阅套餐ID
        uint256 expiry;    // 订阅到期时间（秒）
        bool paused;       // 是否暂停订阅
    }

    // 每个地址 → 对应的订阅信息
    mapping(address => Subscription) public subscription;
    // 每个套餐 → 价格（单位：wei，1 ETH = 1e18 wei）
    mapping(uint8 => uint256) public planPrices;
    // 每个套餐 → 持续时间（单位：秒）
    mapping(uint8 => uint256) public planDuration;
}