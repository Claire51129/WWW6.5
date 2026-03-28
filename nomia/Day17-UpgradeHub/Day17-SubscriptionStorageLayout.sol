 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//separate storage from logic 共享的存储布局模板
contract SubscriptionStorageLayout {
    //现在代理要把调用转发给哪个逻辑合约
    address public logicContract;
    //谁有权限升级逻辑合约
    address public owner;

    //subscription的数据结构
    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }
    
    //每个地址的订阅信息/价格/订阅时长
    mapping(address => Subscription) public subscriptions;
    mapping(uint8 => uint256) public planPrices;
    mapping(uint8 => uint256) public planDuration;

}

