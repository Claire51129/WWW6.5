// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {
    address public logicContract;
    address public owner;

    struct Subscription {//创建结构体
        uint8 planId;
        uint256 expiry;//一个时间戳 表示会员到期
        bool paused;//合约是否暂停
    }

    mapping(address => Subscription) public subscriptions;//誰订阅了什么套餐
    mapping(uint8 => uint256) public planPrices;//这个套餐多少钱
    mapping(uint8 => uint256) public planDuration;//这个套餐什么时候过期
}
//将逻辑和数据分开，这个合约只有变量