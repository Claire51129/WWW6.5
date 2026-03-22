// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SubscriptionStorageLayout
 * @dev 这是一个专门用于存储订阅数据的合约。
 * 采用了逻辑与存储分离的设计模式（Proxy Pattern 基础），
 * 确保后续升级逻辑合约时，用户订阅数据不会丢失。
 */
contract SubscriptionStorageLayout {
    
    address public logicContract; // 业务逻辑合约地址
    address public owner; // 合约管理员

    struct Subscription {
        uint8 planId; // 套餐等级
        uint256 expiry; // 到期时间
        bool paused; // 暂停套餐
    }

    mapping(address => Subscription) public subscriptions; // 地址对应套餐方案
    mapping(uint8 => uint256) public planPrices; // 套餐等级对应价格
    mapping(uint8 => uint256) public planDuration; // 套餐等级对应持续时间

}