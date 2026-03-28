// 天气机器(Oracle) 假装自己是一个“天气数据提供商”，告诉你今天下了多少雨
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";  // 引入一个“标准接口”：老师规定天气机器必须会回答哪些问题
import "@openzeppelin/contracts/access/Ownable.sol";    // 引入“谁是老板”的功能：只有老板可以做某些事情

contract MockWeatherOracle is AggregatorV3Interface, Ownable {   //这是一个天气合约，它必须符合Chainlink的格式，还有一个“老板”
    uint8 private _decimals;    //状态变量：存数据的盒子
    string private _description;    //描述：eg降雨数据
    uint80 private _roundId;   //第几次更新，像第几局游戏
    uint256 private _timestamp;   //更新时间
    uint256 private _lastUpdateBlock;   //上次更新是在第几个区块

    constructor() Ownable(msg.sender) {    //构造函数（出生时执行）——合约一创建，把你设为老板
        _decimals = 0; // Rainfall in whole millimeters；小数位数（这里是0，表示没有小数）——雨量是整数
        _description = "MOCK/RAINFALL/USD";   //描述这个数据
        _roundId = 1;    //初始化一些数据
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 标准接口函数（必须有）
    function decimals() external view override returns (uint8) {   //返回：有没有小数
        return _decimals;
    }

    function description() external view override returns (string memory) {    
        return _description;    //返回描述
    }

    function version() external pure override returns (uint256) {    //返回版本号
        return 1;    //这里写死1
    }

    // 核心函数：获取雨量
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    function latestRoundData()    //（最重要）外部的人问“现在下了多少雨？”
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);    //返回：重点为"_rainfall()"
    }

    // 随机下雨（关键）Function to get current rainfall with random variation 假装随机下雨
    function _rainfall() public view returns (int256) {
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm；生成0-999的随机数
        return int256(randomFactor);    //返回“今日雨量”
    }

    // 更新天气 Function to update random rainfall
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 任何人都可以调用：“刷新天气” Function to force update rainfall (anyone can call)
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}


// 这是一个“如果天气不好就自动赔钱”的保险机器人
// 1、合约不会自己知道现实世界，所以需要Oracle；
// 2、Oracle=数据提供者，负责提供天气、价格、比赛结果
// 3、合约只负责“判断+执行”，如条件成立→自动打钱