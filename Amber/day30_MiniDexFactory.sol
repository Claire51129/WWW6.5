// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30_MiniDexPair.sol";

/// @title MiniDexFactory - DEX 池子工厂
/// @notice 用于创建和管理 MiniDexPair 池子
contract MiniDexFactory is Ownable {

    // 保存所有池子地址
    MiniDexPair[] public allPairs;

    // 双重映射：tokenA => tokenB => 池子地址
    mapping(address => mapping(address => address)) public getPair;

    /// @notice 当新池子创建时触发
    event PairCreated(address indexed tokenA, address indexed tokenB, address pair, uint256 allPairsLength);

    /// @notice 构造函数，传入 owner
    /// @param _owner 工厂所有者地址
    constructor(address _owner) Ownable(_owner) {}

    /// @notice 创建新的交易对池子
    /// @param _tokenA 第一个代币地址
    /// @param _tokenB 第二个代币地址
    /// @return pair 新创建的 MiniDexPair 地址
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != _tokenB, "Identical tokens");
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair exists");

        // 部署新的 MiniDexPair 合约
        MiniDexPair newPair = new MiniDexPair(_tokenA, _tokenB);

        // 保存池子信息
        getPair[_tokenA][_tokenB] = address(newPair);
        getPair[_tokenB][_tokenA] = address(newPair); // 双向映射
        allPairs.push(newPair);

        emit PairCreated(_tokenA, _tokenB, address(newPair), allPairs.length);

        return address(newPair);
    }

    /// @notice 返回所有池子数量
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    /// @notice 根据索引返回池子地址
    /// @param index 池子数组索引
    function getPairAtIndex(uint256 index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return address(allPairs[index]);
    }
}
