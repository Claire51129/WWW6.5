 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//只保存状态变量——它不包含任何函数
//将存储与逻辑分离
contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;

    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }

    mapping(address => Subscription) public subscriptions;
    mapping(uint8 => uint256) public planPrices;
    mapping(uint8 => uint256) public planDuration;
}

