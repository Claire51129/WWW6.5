// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 Chainlink 的价格预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 模拟天气预言机 - 用于本地测试的假预言机
contract MockWeatherOracle is AggregatorV3Interface {

    uint8 private _decimals;        // 数据精度（小数位数）
    string private _description;    // 预言机描述信息
    uint80 private _roundId;        // 当前轮次 ID（每次更新数据 +1）
    uint256 private _timestamp;     // 最近一次数据更新的时间戳

    // 构造函数 - 初始化预言机参数
    constructor() {
        _decimals = 0;                          // 精度为 0，表示返回整数（毫米）
        _description = "Mock Rainfall Oracle";  // 这是一个"降雨量预言机"
        _roundId = 1;                           // 从第 1 轮开始
        _timestamp = block.timestamp;           // 记录部署时间
    }

    // 返回数据精度 - Chainlink 接口要求实现的函数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 返回预言机描述
    function description() external view override returns (string memory) {
        return _description;
    }

    // 返回预言机版本号
    function version() external pure override returns (uint256) {
        return 1;
    }

    // 获取指定轮次的数据 - Chainlink 接口要求的函数
    function getRoundData(uint80) external view override returns (
        uint80 roundId,
        int256 answer,          // 这就是实际的数据值（降雨量）
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 获取最新一轮的数据 - 最常用的函数
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,          // 最新的降雨量数据
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 模拟降雨量数据（0-100 毫米）- 私有函数，内部使用
    function _rainfall() private view returns (int256) {
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender
        )));
        return int256(pseudoRandom % 101);  // 0-100 毫米
    }

    // 手动更新数据 - 模拟 Chainlink 节点定期推送新数据
    function updateData() external {
        _roundId++;
        _timestamp = block.timestamp;
    }
}