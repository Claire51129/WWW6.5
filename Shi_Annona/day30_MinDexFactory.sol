
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30_MinDexPair.sol"; 

contract MiniDexFactory is Ownable {
    //每次通过createPair()创建新配对时，这个事件就会触发
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);
    //这是一个双重映射，用于存储每个创建的配对的部署地址,两个方向都存储，所以用户可以查询配对，无论代币顺序如何，因为是Public所以solidity自动创建查询函数
    mapping(address => mapping(address => address)) public getPair;
    //创建的合约
    address[] public allPairs;

    constructor(address _owner) Ownable(_owner) {}
    //部署新的池子
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Identical tokens");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");

        // 为一致性排序代币，每次查询都先排序
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        pair = address(new MiniDexPair(token0, token1));
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;

        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}

