 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//是布局变量的蓝图，逻辑和代理合约可以使用，这样就相当于大家的底层架构对齐了，这个大合约依靠是delegatecall，用它需要两个合约的变量布局相同，不然很危险！
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