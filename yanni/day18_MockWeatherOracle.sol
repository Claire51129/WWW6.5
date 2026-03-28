// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Chainlink 预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 权限控制（owner）
import "@openzeppelin/contracts/access/Ownable.sol";

// 模拟天气预言机（用于测试降雨数据）
contract MockWeatherOracle is AggregatorV3Interface, Ownable {

    // 数据精度（这里为0，表示整数毫米）
    uint8 private _decimals;

    // 数据描述
    string private _description;

    // 当前轮次ID（模拟Chainlink轮次）
    uint80 private _roundId;

    // 最近更新时间
    uint256 private _timestamp;

    // 上一次更新时的区块号（用于生成随机数）
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0; // 降雨量以“毫米整数”表示
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 返回精度
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 返回描述
    function description() external view override returns (string memory) {
        return _description;
    }

    // 版本号（固定为1）
    function version() external pure override returns (uint256) {
        return 1;
    }

    // 获取指定轮次的数据（这里返回模拟数据）
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        // 返回当前“伪随机降雨量”
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // 获取最新一轮数据
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 生成“伪随机”降雨量（仅用于测试，不安全）
    function _rainfall() public view returns (int256) {

        // 距离上次更新经过的区块数
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;

        // 利用区块信息生成伪随机数（不安全，仅测试用）
        uint256 randomFactor = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.coinbase,
                    blocksSinceLastUpdate
                )
            )
        ) % 1000; // 生成 0 ~ 999 的数

        // 返回降雨量（单位：毫米）
        return int256(randomFactor);
    }

    // 内部函数：更新一轮数据
    function _updateRandomRainfall() private {
        _roundId++;                     // 新轮次
        _timestamp = block.timestamp;   // 更新时间
        _lastUpdateBlock = block.number;// 更新区块
    }

    // 外部函数：触发更新（任何人都可以调用）
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}