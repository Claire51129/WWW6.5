// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 共享内存蓝图
// 定义代理和逻辑合约的内存结构，利于更新前后的合约可以共享和操作相同数据（delegatecall很需要）
contract SubscriptionStorageLayout {

    // 存储当前实现合约地址，代理合约用来知道使用delegatecall转发调用的地方
    // 可以通过代理合约中的upgradeTo()更新地址
    address public logicContract;

    // 记录合约管理员和部署者，可以实现权限管理
    address public owner;

    struct Subscription{

        // 用户套餐标识符（等级）
        uint8 planId;

        // 记录订阅何时到期
        uint256 expiry;

        // 在不删除用户的情况下临时停用用户订阅
        bool paused;
    }

    // 用于跟踪每个用户的有效套餐、到期时间和暂停状态
    mapping(address => Subscription) public subscription;
    
    // 定义不同套餐等级的价格（单位为 ETH）
    mapping (uint8 => uint256) public planPrices;

    // 定义每个套餐持续多久（单位为秒）
    mapping (uint8 => uint256) public  planDuration;
}