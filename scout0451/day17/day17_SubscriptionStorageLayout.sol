 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    
    //储存包含实际功能的逻辑合约的地址，可通过代理合约中upgradeTo() 函数更新地址
    address public logicContract;
    address public owner;

    struct Subscription {
        uint8 planId;    //用户套餐的标识符代表不同的层级（例如，基础版、专业版、高级版）。
        uint256 expiry;  //订阅何时到期
        bool paused;     //开关：用于在不删除的情况下临时停用用户的订阅
    }

    //跟踪每个用户的有效套餐、其到期时间和暂停状态
    mapping(address => Subscription) public subscriptions;
    //每个套餐需要多少 ETH
    mapping(uint8 => uint256) public planPrices;
    //持续时间
    mapping(uint8 => uint256) public planDuration;
}

