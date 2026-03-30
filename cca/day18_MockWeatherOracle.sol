// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//此接口需要的函数：latestRoundData() decimals() desctiption() version()
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;//decimals使精度标准化 写10** ··.decimals自动适应chainlink喂价精度 还原价格到可读格式
    string private _description;
    uint80 private _roundId;//轮次周期 数据的序列号 每次聚合一次新的数据产生新的roundId 借助它精确地查询某一时刻的价格数据
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0; // 降雨量以整毫米为单位
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }
    
    //decimals函数作用是告诉外部应用程序（如前端 UI 或其他智能合约）该整数包含多少位“虚构”的小数。
    //例如，如果预言机返回价格为 5000 且 decimals 为 2，则表示真实价格是 50.00
    function decimals() external view override returns (uint8) {
        return _decimals;//返回0表示告诉外界我给出的数字就是最终的毫米数，不需要再移动小数点
    }

    function description() external view override returns (string memory) {
        return _description;
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {//updatedAt时间戳用以检查数据是新鲜的 防止使用过期价格导致被套利
    //roundId数据时间坐标 answeredInRound数据提交轮次 代表数据被成功提交并记录在链上的那个轮次
    //极端情况下 去中心化的复杂网络中出现延迟和失败 answeredInRound提供数据新鲜度检查工具
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    //模拟降雨发生器
    function _rainfall() public view returns (int256) {
        // 计算自上次更新以来经过的区块数
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        //使用三个随机源（Entropy）来生成伪随机降雨值
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
    }

    //用于增加轮数(模拟新数据)
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 任何人都可以调用的 public 函数来更新“预言机”数据。
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}


