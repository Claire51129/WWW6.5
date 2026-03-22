// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;
    
    struct Subscription { //定义了一个名为 Subscription 的结构体
        uint8 planId;//计划 ID
        uint256 expiry;//expiry
        bool paused;//暂停状态
    }
    
    mapping(address => Subscription) public subscriptions;//将地址映射到 Subscription 结构体的公共映射，名为 subscriptions。
    mapping(uint8 => uint256) public planPrices;//将 8 位无符号整数映射到 256 位无符号整数的公共映射，名为 planPrices
    mapping(uint8 => uint256) public planDuration;//将 8 位无符号整数映射到 256 位无符号整数的公共映射，名为 planDuration
}