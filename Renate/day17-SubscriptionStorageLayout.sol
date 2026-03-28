// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SubscriptionStorageLayout - 订阅存储布局合约
// 这是可升级合约架构中的基础合约
// 定义了所有存储变量，确保代理合约和逻辑合约的存储布局一致
// 存储布局的一致性是可升级合约的关键！
contract SubscriptionStorageLayout {

    // 当前逻辑合约地址
    // 代理合约使用此地址进行 delegatecall
    address public logicContract;

    // 合约所有者地址
    // 拥有升级合约等特权操作权限
    address public owner;

    // 订阅信息结构体
    // planId: 订阅计划 ID（如 1=基础版, 2=高级版）
    // expiry: 订阅过期时间戳（秒）
    // paused: 是否处于暂停状态（V2 新增字段）
    struct Subscription {
        uint8 planId;
        uint256 expiry;
        bool paused;
    }

    // 用户地址到订阅信息的映射
    // 存储每个用户的订阅详情
    mapping(address => Subscription) public subscriptions;

    // 计划 ID 到价格的映射
    // 存储每个订阅计划的价格（wei）
    mapping(uint8 => uint256) public planPrices;

    // 计划 ID 到持续时间的映射
    // 存储每个订阅计划的有效期（秒）
    mapping(uint8 => uint256) public planDuration;

    // 安全间隙 - 防止未来升级时存储冲突
    // 这是一个预留的存储空间，用于未来的存储变量
    // 如果不预留，添加新变量可能会与继承合约的存储发生冲突
    // 50 个 uint256 槽位提供了充足的安全缓冲
    uint256[50] private __gap;
}

// 存储布局一致性规则:
//
// 1. 变量顺序很重要:
//    - 代理合约和逻辑合约必须使用相同的存储布局
//    - 不能在现有变量之间插入新变量
//    - 只能在末尾添加新变量
//
// 2. 继承关系:
//    - 基础合约（如本合约）应该在最前面定义存储
//    - 继承合约会在基础合约之后分配存储
//
// 3. __gap 的作用:
//    - 为未来升级预留存储空间
//    - 防止继承合约的存储与基础合约发生冲突
//    - 如果需要添加新变量，可以减少 __gap 的大小
//
// 4. 升级时的注意事项:
//    - 永远不要删除或重新排序现有变量
//    - 永远不要改变现有变量的类型
//    - 新变量只能添加在现有变量之后
