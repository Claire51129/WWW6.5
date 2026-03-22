// SPDX-License-Identifier: MIT
// 代码开源协议，MIT是最宽松的协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本为0.8.0及以上

contract SubscriptionStorageLayout {
// 定义一个合约，叫"订阅存储布局"
// 这是一个存储合约，只存数据，不包含业务逻辑
// 配合逻辑合约使用，实现可升级功能

    address public logicContract;
    // 逻辑合约的地址
    // 作用：指向当前正在使用的业务逻辑合约
    // 用户调用时，会通过这个地址找到实际执行的代码
    // 升级时：修改这个地址，指向新的逻辑合约

    address public owner;
    // 合约所有者地址
    // 作用：只有所有者可以升级合约（修改logicContract）
    // 通常是部署者或者DAO

    struct Subscription {
    // 定义"订阅"结构体
        uint8 planId;
        // 套餐ID（0-255）
        // 比如：1=基础版，2=专业版，3=旗舰版
        
        uint256 expiry;
        // 订阅到期时间（Unix时间戳）
        // 例如：1735689600 表示2025年1月1日到期
        
        bool paused;
        // 是否暂停订阅
        // true = 暂停中，不能享受服务
        // false = 正常使用中
    }

    mapping(address => Subscription) public subscriptions;
    // 映射：用户地址 → 订阅信息
    // 作用：记录每个用户的订阅详情
    // 包含：套餐ID、到期时间、是否暂停

    mapping(uint8 => uint256) public planPrices;
    // 映射：套餐ID → 价格
    // 作用：记录每个套餐的价格（单位：wei）
    // 例如：planPrices[1] = 0.01 ether

    mapping(uint8 => uint256) public planDuration;
    // 映射：套餐ID → 有效期时长
    // 作用：记录每个套餐的有效期（单位：秒）
    // 例如：planDuration[1] = 30 days
}