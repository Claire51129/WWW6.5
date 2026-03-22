 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//母合约只保存状态变量，不包含任何函数，子合约可导入和继承它
contract SubscriptionStorageLayout {
    //地址，子合约可通过delegatecall调用，也可通过upgradeTo() 函数
    address public logicContract;
    //合约的管理员或部署者
    address public owner;
    
    struct Subscription {
        //用户套餐的标识符
        uint8 planId;
        //一个时间戳，指示订阅何时到期
        uint256 expiry;
        //允许用户暂停或恢复他们的套餐
        bool paused;
    }
    //跟踪每个用户的有效套餐、其到期时间和暂停状态
    mapping(address => Subscription) public subscriptions;
    //定义了每个套餐需要多少 ETH
    mapping(uint8 => uint256) public planPrices;
    //每个套餐持续多久
    mapping(uint8 => uint256) public planDuration;
}

