// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Day17 Storage Layout Demo
 * @dev 演示 Solidity 存储布局、变量打包、结构体对齐及映射/数组的存储位置计算
 * 
 * 文件名: day17_storage_layout.sol
 * 合约名: day17_storage_layout
 */
contract day17_storage_layout {
    
    // --- 第 0 号槽 (Slot 0) ---
    // uint8 (1 byte) + uint8 (1 byte) + uint256 (32 bytes) 
    // 注意：uint256 会独占一个槽，所以前面的两个 uint8 会被打包到下一个可用位置吗？
    // 不！Solidity 按声明顺序存储。
    // 规则：如果当前槽剩余空间不足以放下下一个变量，则开启新槽。
    
    uint8 public a = 10;      // Slot 0, Offset 0 (1 byte)
    uint8 public b = 20;      // Slot 0, Offset 1 (1 byte)
    // 此时 Slot 0 还剩 30 字节。
    uint256 public c = 100;   // Slot 1 (因为 uint256 需要 32 字节，Slot 0 剩的不够，所以新开 Slot 1)
    
    // --- 第 2 号槽 (Slot 2) ---
    // 演示结构体打包
    struct MyStruct {
        uint8 x;      // 1 byte
        uint256 y;    // 32 bytes -> 强制新槽
        uint8 z;      // 1 byte
    }
    
    MyStruct public myStruct; // 结构体本身从 Slot 2 开始
    
    // 初始化结构体数据 (在 constructor 中)
    // myStruct.x -> Slot 2
    // myStruct.y -> Slot 3 (因为 y 是 uint256)
    // myStruct.z -> Slot 4 (因为 Slot 3 被 y 占满了)
    
    // --- 映射 (Mapping) ---
    // 映射本身不占具体槽位，只占一个“虚拟”槽位编号用于计算
    mapping(address => uint256) public balances; 
    // balances 的槽位编号是 5 (接在 myStruct 之后)
    // 实际数据位置 = keccak256(abi.encode(key, slotId))
    
    // --- 动态数组 (Dynamic Array) ---
    uint256[] public numbers;
    // numbers 的槽位编号是 6
    // 数组长度存在 Slot 6
    // 数组元素存在从 keccak256(6) 开始的连续槽位

    constructor() {
        // 初始化结构体以便观察
        myStruct.x = 55;
        myStruct.y = 999;
        myStruct.z = 77;
        
        // 初始化映射
        balances[msg.sender] = 12345;
        
        // 初始化数组
        numbers.push(111);
        numbers.push(222);
        numbers.push(333);
    }

    /**
     * @dev 获取指定地址的原始存储数据 (辅助调试用)
     * 在 Remix 的 "Debug" 面板或调用 eth_getStorageAt RPC 时使用
     * 这里只是返回一些提示，实际查看需用底层方法
     */
    function getStorageInfo() external pure returns (string memory) {
        return "Check Remix 'Storage' panel or use eth_getStorageAt RPC call";
    }

    /**
     * @dev 演示手动计算映射的存储位置
     * @param key 映射的键 (地址)
     * @return 存储该键值的槽位索引 (十六进制字符串)
     */
    function calculateMappingSlot(address key) external pure returns (bytes32) {
        uint256 slotId = 5; // balances 变量的槽位 ID
        // 计算公式：keccak256(abi.encodePacked(key, slotId))
        // 注意：Solidity 中 mapping 的计算是 abi.encode(key, slotId) 然后做 hash
        return keccak256(abi.encode(key, slotId));
    }

    /**
     * @dev 演示手动计算动态数组元素的存储位置
     * @param index 数组索引
     * @return 存储该元素的槽位索引
     */
    function calculateArraySlot(uint256 index) external pure returns (bytes32) {
        uint256 slotId = 6; // numbers 变量的槽位 ID
        // 数组长度存在 slotId
        // 元素存在 keccak256(slotId) + index
        bytes32 baseSlot = keccak256(abi.encode(slotId));
        return bytes32(uint256(baseSlot) + index);
    }
    
    /**
     * @dev 故意制造一个未打包的例子来对比 Gas 消耗
     */
    struct BadStruct {
        uint256 a; // 32 bytes
        uint8 b;   // 1 byte (浪费 31 bytes)
        uint8 c;   // 1 byte (浪费 31 bytes，因为它们不能跨越槽位和 a 打包)
    }
    
    BadStruct public badStruct;
    // badStruct.a -> Slot 7
    // badStruct.b -> Slot 8
    // badStruct.c -> Slot 8 (b 和 c 可以打包在 Slot 8)
    
    function initBadStruct() external {
        badStruct.a = 1000;
        badStruct.b = 1;
        badStruct.c = 2;
    }
}