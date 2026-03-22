// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//Chainlink 的标准预言机接口
//import "@openzeppelin/contracts/access/Ownable.sol";

import "./day18_AggregatorV3Interface.sol";
import "./day18_Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable 
{
    uint8 private _decimals;//数据精度
    string private _description;//提供人类可读的描述
    uint80 private _roundId;//数据更新周期
    uint256 private _timestamp;//上次更新时间
    uint256 private _lastUpdateBlock;//跟踪上次更新发生时的块，用于添加随机性

    constructor() Ownable(msg.sender) 
    {
        _decimals = 0; // 不需要小数
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;//存储当前时间/区块以模拟数据的新鲜度
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external view override returns (string memory) {
        return _description;
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    //访问历史数据
    function getRoundData(uint80 _roundId_)external view override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    //获取最新数据，CropInsurance 合约将调用此函数，以获取当前降雨量
    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    //模拟降雨发生器，获取随机数
    function _rainfall() public view returns (int256) {
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
    }

    // Function to update random rainfall
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    //调用以更新预言机数据 (anyone can call)
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}
