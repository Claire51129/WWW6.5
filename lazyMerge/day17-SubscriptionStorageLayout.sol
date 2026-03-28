 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// 只保存状态变量
contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;

    struct Subscription {
        uint8 planId; // 用户套餐的标识符
        uint256 expiry; // 时间戳
        bool paused;
    }

    mapping(address => Subscription) public subscriptions;
    mapping(uint8 => uint256) public planPrices;
    mapping(uint8 => uint256) public planDuration;
}

