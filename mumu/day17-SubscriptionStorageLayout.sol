// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
  @notice 订阅存储的布局合约
 */

contract SubscriptionStorageLayout{
    address public logicContract;
    address public owner;

    struct Subscription{
        uint8 planId;
        uint256 expiry;
        bool paused;
    }

    // user=》subcription
    mapping(address => Subscription) public subscriptions;
    // 订阅价格
    mapping (uint8=>uint256) public planPrices;
    // 订阅时长
    mapping(uint8 => uint256) public planDuration;
}


/**
重难点：代理模式和内联汇编的复杂性

两种合约：
1.代理合约：
    存储所有数据
    接受所有的函数调用
    将调用委托给逻辑合约
    地址永远不改变

2. 逻辑合约
    包含业务逻辑
    不存储数据
    可以被替换升级
    通过delegatecall执行


知识点：
1. 可升级合约
    一个合约部署后，就无法更改；所以针对（1）代码中存在漏洞（2）想要新增功能的两种情况
    我们需要将合约设计成可升级的。

核心： 将存储与逻辑分离。而逻辑是可以升级的，也通过可插拔的形式进行调用
（1）部署一个存储数据的合约 ———— 我们称之为代理
（2）部署一个包含逻辑的合约 ———— the actual code
（3）代理使用delegatecall 来执行外部合约的逻辑，也就是在存储合约中使用delegatecall来调用logic合约的代码逻辑

 */