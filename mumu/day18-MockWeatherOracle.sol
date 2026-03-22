// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
  @notice 模拟天气预言机合约
  @dev 模拟chainlink风格的预言机，随机生成降雨值
 */

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {

    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;  // 为啥是uint80？
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;  // 最后更新的块？

    constructor() Ownable(msg.sender){
        _decimals = 0; // rainfall in whole millimeters
        _description = "MOCK/RAINFALL/USD"; // 啥意思？
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
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

    // 因为我们这里没有记录每一轮的数据，所以实际上这里getRoundData和latesRoundData的功能实际上是一样的
    function getRoundData(uint80) external view override returns(
        uint80 roundId,
        int256 answer,  // 降雨量可能是负数？
        uint256 startedAt,  // 秒级时间戳不是32位就够了吗？为啥要用这么多位？
        uint256 updateAt, 
        uint80 answerInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    function latestRoundData()external view override returns(
        uint80 roundId,
        int256 answer,  // 降雨量可能是负数？
        uint256 startedAt,  // 秒级时间戳不是32位就够了吗？为啥要用这么多位？
        uint256 updateAt, 
        uint80 answerInRound
    ){
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

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

    // 提供一个用于测试的手动更新数据的接口
    function updateData() external{
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }
}