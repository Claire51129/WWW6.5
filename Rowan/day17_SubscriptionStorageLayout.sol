// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    这个合约只负责定义存储结构（Storage Layout）
    Proxy 合约和 Logic 合约都会继承它，
    从而确保它们使用完全相同的 storage 布局。

    在 delegatecall 架构中：
    - 逻辑代码在 Logic 合约
    - 存储数据在 Proxy 合约
    - 所以 storage 结构必须完全一致
*/

contract SubscriptionStorageLayout {

    // 当前逻辑合约地址（Proxy 会 delegatecall 到这个地址）
    address public logicContract;

    // 管理员地址（可以升级逻辑合约）
    address public owner;

    /*
        订阅结构体
        保存每个用户的订阅信息
    */
    struct Subscription {

        // 订阅的套餐 ID
        uint8 planId;

        // 订阅到期时间（时间戳）
        uint256 expiry;

        // 是否暂停
        bool paused;
    }

    // 用户地址 => 订阅信息
    mapping(address => Subscription) public subscriptions;

    // 套餐ID => 价格
    mapping(uint8 => uint256) public planPrices;

    // 套餐ID => 持续时间（秒）
    mapping(uint8 => uint256) public planDuration;
}
