// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//SubscriptionStorageLayout.sol 蓝图,定义了：谁是所有者,逻辑合约的地址在哪里,实际的存储布局：用户订阅、套餐价格、持续时间等
//SubscriptionStorage.sol 代理（proxy）合约，存储数据，通过delegatecall将所有逻辑委托给外部合约执行，它可以随时升级到新的逻辑合约
//SubscriptionLogicV1.sol
//SubscriptionLogicV2.sol升级版本

contract SubscriptionStorageLayout 
{
    address public logicContract;//存储当前实现合约的地址，可以通过代理中的 upgradeTo() 函数更新这个地址
    address public owner;

    struct Subscription 
    {
        uint8 planId;//用户套餐标识符
        uint256 expiry;//订阅何时到期
        bool paused;//在不删除的情况下临时停用用户的订阅
    }

    mapping(address => Subscription) public subscriptions;//跟踪每个用户的有效套餐、其到期时间和暂停状态
    mapping(uint8 => uint256) public planPrices;
    mapping(uint8 => uint256) public planDuration;
}
