 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 它不包含任何函数（除了后面继承的逻辑）。存储与逻辑分离
contract SubscriptionStorageLayout {
    address public logicContract;//当前实现合约的地址
    address public owner;//合约的管理员或部署者

    struct Subscription {
        uint8 planId;//用户套餐的标识符
        uint256 expiry;//订阅有效期
        bool paused;// 服务开关
    }
// 跟踪每个用户的有效套餐、其到期时间和暂停状态
    mapping(address => Subscription) public subscriptions;
    // 每个套餐planId需要多少 ETH
    mapping(uint8 => uint256) public planPrices;
     // 每个套餐的持续时间（以秒为单位）
    mapping(uint8 => uint256) public planDuration;


}