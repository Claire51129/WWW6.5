// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30_MiniDexPair.sol";

//代币池启动台
contract MiniDexFactory is Ownable {
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);

    mapping(address => mapping(address => address)) public getPair;//存储每个创建的配对的部署地址
    address[] public allPairs;//存储这个工厂创建的所有配对合约

    constructor(address _owner) Ownable(_owner) {}//设置所有者

    //部署新的流动性池
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Identical tokens");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");

        // 我们总是以(token0, token1)的顺序存储配对，其中token0 < token1
        //避免重复
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        pair = address(new MiniDexPair(token0, token1));//实际的链上流动性池
        //存储配对
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    //获取工厂创建的配对总数
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    //通过其在列表中的位置检索特定的配对合约
    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}