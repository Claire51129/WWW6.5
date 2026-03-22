 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//一份规格说明书，它告诉代理合约和后续所有的逻辑版本（V1、V2 等）：“这就是我们共享的数据排列方式，请严格遵守。”
contract SubscriptionStorageLayout{
    address public logicContract;
    address public owner;

    struct Subscription {
        uint8 planId;//用户套餐的标识符，如 1, 2, 或 3，代表不同的层级
        uint256 expiry;//一个时间戳，指示订阅何时到期。
        bool paused;//一个开关，用于在不删除的情况下临时停用用户的订阅
    }

    mapping(address => Subscription) public subscriptions;//跟踪每个用户的有效套餐、其到期时间和暂停状态
    mapping(uint8 => uint256) public planPrices;//这定义了每个套餐需要多少 ETH。
    mapping(uint8 => uint256) public planDuration;//这告诉我们每个套餐持续多久（以秒为单位）。
}
