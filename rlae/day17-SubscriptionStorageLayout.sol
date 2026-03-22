// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//通过导入和继承这个布局，两个合约可以共享和操作相同的数据，前提是它们的内存布局顺序相同
contract SubscriptionStorageLayout{
    address public  logicContract; //这存储了当前实现合约的地址—逻辑合约 , 以后可以通过代理中的 upgradeTo() 函数更新这个地址，以切换到新版本的逻辑。
    address public owner; //合约的管理员或部署者

    struct Subscription {
        uint8 planId; //用户套餐的标识符
        uint256 expiry; //Unix 时间戳是大数字
        bool paused; //一个开关，用于在不删除的情况下临时停用用户的订阅
    }

    mapping (address=> Subscription) public subscriptions;
    mapping (uint8=>uint256) public planPrices; //iD=>prices //定义了每个套餐需要多少 ETH
    mapping(uint8 => uint256) public planDuration; ////iD=>duration 每个套餐持续多久（以秒为单位）

}