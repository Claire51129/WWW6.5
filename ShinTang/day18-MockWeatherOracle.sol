
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// https://github.com/smartcontractkit/chainlink-evm/blob/develop/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 模拟天气预言机，提供降雨量数据接口
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    // 初始化轮次与时间戳，设置所有者
    constructor() Ownable(msg.sender) {
        _decimals = 0; // Rainfall in whole millimeters
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 返回小数位（此处为 0，毫米整数）
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 返回数据源描述字符串
    function description() external view override returns (string memory) {
        return _description;
    }

    // 返回接口版本号
    function version() external pure override returns (uint256) {
        return 1;
    }

    // 按轮次返回数据与时间戳等字段
    function getRoundData(uint80 _roundId_) external view override
            returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // 返回当前最新一轮的数据与时间戳等字段
    function latestRoundData() external view override
            returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 基于区块信息生成伪随机降雨量
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

    // 触发一次内部轮次与时间更新
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }

    // 内部更新轮次与时间戳（外部不可调用）
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

}

