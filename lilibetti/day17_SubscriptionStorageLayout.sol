//可升级的订阅系统之蓝图。

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;

    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }

    mapping(address => Subscription) public subscriptions; //看用户情况
    mapping(uint8 => uint256) public planPrices; //看套餐要多少钱
    mapping(uint8 => uint256) public planDuration; //看套餐时长
}

