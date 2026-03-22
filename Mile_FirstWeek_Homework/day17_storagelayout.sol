// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Day17 Storage Layout
 * @dev 定义所有合约共享的存储结构。
 * 
 * ⚠️ 关键规则：
 * 1. 文件名必须为：day17_storagelayout.sol
 * 2. 合约名必须为：day17_storagelayout
 * 3. 逻辑合约和代理合约都必须继承此合约，以保证存储槽位顺序一致。
 */
contract day17_storagelayout {
    // Slot 0
    address public logicContract;
    // Slot 1
    address public owner;
    
    // 结构体定义 (不占独立槽位，嵌入在 mapping 中)
    struct Subscription {
        uint8 planId;   // 1 byte
        uint256 expiry; // 32 bytes (强制新槽)
        bool paused;    // 1 byte (新槽)
    }
    
    // 存储映射
    // Slot 2: subscriptions mapping
    mapping(address => Subscription) public subscriptions;
    
    // Slot 3: planPrices mapping
    mapping(uint8 => uint256) public planPrices;
    
    // Slot 4: planDuration mapping
    mapping(uint8 => uint256) public planDuration;

    // 事件
    event Upgraded(address indexed newImplementation);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}