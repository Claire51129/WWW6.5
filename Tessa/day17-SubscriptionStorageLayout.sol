// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SubscriptionStorageLayout {    //统一存储蓝图
    address public logicContract;    //当前“大脑地址”
    address public owner;    //谁是老板（可以升级的人）
    
    struct Subscription {
        uint8 planId;    //planId: 买的是哪个套餐
        uint256 expiry;    //到期时间
        bool paused;    //是否暂停
    }

    mapping(address => Subscription) public subscriptions;   // 钱包地址 → 会员信息
    mapping(uint8 => uint256) public planPrices;    //套餐价格
    mapping(uint8 => uint256) public planDuration;    //套餐时长
    
}



// 普通合约=写死的机器人（不能改）；可升级合约=换脑子但不换身体
// StorageLayout:存储蓝图（数据结构）。所有合约必须用同一套“内存结构”，该合约只定义“数据结构”，不写逻辑
// Proxy:数据仓库+转发器。类似于会员俱乐部的保险箱，用于存钱、存会员信息、永远不换
// LogicV1:第一版功能。类似于会员俱乐部中的店长，负责规则（充值、订阅）、可以换人
// LogicV2:升级版功能。升级就是换店长，不换保险箱，多了暂停功能