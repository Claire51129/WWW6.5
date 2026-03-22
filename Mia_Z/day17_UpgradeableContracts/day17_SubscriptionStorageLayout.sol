// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 这是一个独立的合约，**只保存状态变量**——它不包含任何函数（除了后面继承的逻辑）。其思想是**将存储与逻辑分离**，这是代理升级模式的关键部分。

这个布局合约就像一个**蓝图**，定义了代理和逻辑合约的**内存结构**。

通过导入和继承这个布局，两个合约可以**共享和操作相同的数据**，前提是它们的内存布局顺序相同——这对于 `delegatecall` 的正确工作至关重要。
 * 
 * 
 */
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

