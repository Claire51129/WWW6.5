// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 订阅系统存储布局合约 - 这不是一个有功能的合约，而是一个"数据模板"
contract SubscriptionStorageLayout {

    // 逻辑合约的地址 - 存储槽 0
    address public logicContract;

    // 合约所有者 - 存储槽 1
    address public owner;

    // 订阅信息结构体 - 记录用户的订阅状态
    struct Subscription {
        uint8 planId;       // 套餐 ID（0-255，比如 1=月卡、2=季卡、3=年卡）
        uint256 expiry;     // 到期时间（时间戳）
        bool paused;        // 是否暂停订阅
    }

    // 用户地址 => 订阅信息 - 存储槽 2（mapping 本身占一个槽，实际数据通过哈希定位）
    mapping(address => Subscription) public subscriptions;

    // 套餐 ID => 套餐价格（wei）- 存储槽 3
    // 例如：planPrices[1] = 0.01 ether 表示月卡价格 0.01 ETH
    mapping(uint8 => uint256) public planPrices;

    // 套餐 ID => 套餐时长（秒）- 存储槽 4
    // 例如：planDuration[1] = 2592000 表示月卡有效期 30 天
    mapping(uint8 => uint256) public planDuration;
}