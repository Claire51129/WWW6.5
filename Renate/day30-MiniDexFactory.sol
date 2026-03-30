// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 Pair 合约，用于创建新的交易对
import "./day30-MiniDexPair.sol";

/// @title Mini DEX 工厂合约
/// @title Mini DEX Factory
/// @dev 用于创建和管理交易对的工厂合约
/// @dev 每个代币对只能创建一个交易对，避免重复
contract MiniDexFactory {
    
    // ==================== 状态变量 ====================
    
    /// @notice 交易对映射表
    /// @dev tokenA => tokenB => Pair 地址
    /// @dev 使用双重映射来查找两个代币组成的交易对
    mapping(address => mapping(address => address)) public getPair;
    
    /// @notice 所有交易对地址列表
    /// @dev 存储所有已创建的交易对地址
    address[] public allPairs;

    // ==================== 事件 ====================
    
    /// @notice 交易对创建事件
    /// @param token0 代币 0 地址（排序后较小）
    /// @param token1 代币 1 地址（排序后较大）
    /// @param pair 新创建的交易对合约地址
    /// @param pairIndex 交易对在 allPairs 数组中的索引
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256 pairIndex
    );

    // ==================== 核心功能 ====================
    
    /// @notice 创建新的交易对
    /// @param tokenA 第一个代币地址
    /// @param tokenB 第二个代币地址
    /// @return pair 新创建的交易对合约地址
    /// @dev 对代币地址进行排序，确保 token0 < token1
    /// @dev 防止创建重复的交易对
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        // 检查两个地址不相同
        require(tokenA != tokenB, "Identical addresses");
        
        // 检查地址不为零地址
        require(tokenA != address(0) && tokenB != address(0), "Zero address");
        
        // 检查交易对尚未创建
        require(getPair[tokenA][tokenB] == address(0), "Pair already exists");

        // 对代币地址进行排序，确保 token0 < token1
        // 这样可以避免 A-B 和 B-A 被认为是不同的交易对
        // 使用三元运算符进行排序
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        // 部署新的交易对合约
        // 注意：在生产环境中通常使用 create2 来生成确定性地址
        // 但在本教程中使用 new 关键字更简单易理解
        MiniDexPair newPair = new MiniDexPair(token0, token1);
        pair = address(newPair);

        // 更新映射表
        // 存储正向映射：token0 => token1 => pair
        getPair[token0][token1] = pair;
        // 存储反向映射：token1 => token0 => pair
        // 这样无论用户以什么顺序传入代币，都能找到交易对
        getPair[token1][token0] = pair;
        
        // 将新交易对添加到列表
        allPairs.push(pair);

        // 触发交易对创建事件
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
    
    /// @notice 获取所有交易对的数量
    /// @return 交易对总数
    /// @dev view 函数，不消耗 gas
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 工厂模式核心概念:
//    - 工厂合约（Factory）: 用于创建其他合约的合约
//    - 单例模式: 每个代币对只能创建一个交易对
//    - 地址排序: 确保不同顺序的代币对指向同一个交易对
//    - 映射存储: 快速查找交易对地址
//
// 2. 地址排序的重要性:
//    如果没有排序：
//    - 用户可能创建 USDC-WETH 和 WETH-USDC 两个交易对
//    - 导致流动性分散，价格不一致
//    
//    排序后：
//    - 无论用户传入 USDC-WETH 还是 WETH-USDC
//    - 都指向同一个交易对地址
//    - 保持流动性集中
//
// 3. 使用流程:
//    创建交易对:
//    1. 调用 createPair(tokenA, tokenB)
//    2. 工厂合约自动排序地址
//    3. 部署新的 Pair 合约
//    4. 更新映射表和列表
//    
//    查询交易对:
//    1. 调用 getPair[tokenA][tokenB]
//    2. 如果返回非零地址，说明交易对存在
//
// 4. 与 Uniswap V2 Factory 的区别:
//    - 本合约使用 new 关键字部署
//    - Uniswap V2 使用 create2 生成确定性地址
//    - create2 的好处是可以在部署前预测合约地址
//    - 本合约更简单，适合学习理解
//
// 5. 关键知识点:
//    - 工厂设计模式
//    - 合约部署（new 关键字）
//    - 地址排序和映射
//    - 事件日志
//
