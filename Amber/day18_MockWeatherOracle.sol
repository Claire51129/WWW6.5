// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 导入 Chainlink 的预言机接口（用于模拟标准预言机结构）
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 导入 OpenZeppelin 的 Ownable 合约，用于管理员权限控制
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * MockWeatherOracle
 * 模拟天气预言机
 * 
 * 作用：
 * 模拟 Chainlink 预言机接口，返回随机生成的降雨量数据
 */
contract MockWeatherOracle is AggregatorV3Interface, Ownable {

    // 数据小数位数（降雨量使用整数毫米）
    uint8 private _decimals;

    // 数据描述
    string private _description;

    // 当前轮次 ID
    uint80 private _roundId;

    // 上次更新时间
    uint256 private _timestamp;

    // 上次更新区块
    uint256 private _lastUpdateBlock;

    /*
     * 构造函数
     * 部署合约时初始化预言机数据
     */
    constructor() Ownable(msg.sender) {
        _decimals = 0; // 降雨量不需要小数
        _description = "MOCK/RAINFALL/USD"; // 数据描述
        _roundId = 1; // 初始轮次
        _timestamp = block.timestamp; // 当前时间
        _lastUpdateBlock = block.number; // 当前区块
    }

    // 返回数据的小数位数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 返回数据源描述
    function description() external view override returns (string memory) {
        return _description;
    }

    // 返回预言机版本号
    function version() external pure override returns (uint256) {
        return 1;
    }

    /*
     * 根据轮次获取数据
     */
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
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    /*
     * 获取最新一轮数据
     */
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

    /*
     * 生成伪随机降雨量
     * 利用区块信息生成随机值
     */
    function _rainfall() public view returns (int256) {

        // 计算距离上次更新经过的区块数
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;

        // 使用 keccak256 生成随机值
        uint256 randomFactor = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.coinbase,
                    blocksSinceLastUpdate
                )
            )
        ) % 1000; // 降雨范围 0-999 mm

        return int256(randomFactor);
    }

    /*
     * 内部函数
     * 更新降雨数据
     */
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    /*
     * 外部函数
     * 任何人都可以调用以更新降雨量
     */
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}
