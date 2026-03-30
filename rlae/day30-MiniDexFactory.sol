
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol"; //为我们的合约提供访问控制
import "./day30-MiniDexPair.sol"; // 本地导入 
//工厂的整个工作就是为不同的代币组合部署这个合约的新实例 部署多个流动性池合约（MiniDexPair） 确保不创建重复池子
contract MiniDexFactory is Ownable {
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);
    //tokenA和tokenB：配对中的两个代币
    //pairAddress：新MiniDexPair合约的实际部署地址
    //一个uint，作为配对在allPairs数组中的索引

    mapping(address => mapping(address => address)) public getPair; //双重映射
    //getPair[DAI][WETH] = 0x...PairAddress
    //getPair[WETH][DAI] = 0x...SamePairAddress
    //两个方向都存储，所以用户可以查询配对，无论代币顺序如何
    address[] public allPairs; //所有配对合约

    constructor(address _owner) Ownable(_owner) {} //在部署期间接受_owner地址作为输入 该地址直接传递给OpenZeppelin的Ownable构造函数
    //部署新的流动性池
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");//两个代币地址都有效
        require(_tokenA != _tokenB, "Identical tokens"); //代币不相同
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists"); //这个组合的配对还不存在

        // 为一致性排序代币 总是以(token0, token1)的顺序存储配对，其中token0 < token1
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        //部署配对合约

        pair = address(new MiniDexPair(token0, token1));
        //存储配对
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;

        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }
    //获取工厂创建的配对总数的简单方法
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
    //通过其在列表中的位置检索特定的配对合约
    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}