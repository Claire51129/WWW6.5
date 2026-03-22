// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 Chainlink 标准接口：确保我们的 Mock 合约长得和真实预言机一模一样
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockWeatherOracle
 * @dev 模拟降雨量预言机。它实现了 AggregatorV3Interface 接口，
 * 使得其他合约（如保险合约）可以像调用真实 Chainlink 节点一样调用它。
 */
contract MockWeatherOracle is AggregatorV3Interface {
    uint8 private _decimals;      // 精度：降雨量通常取整，设为 0
    string private _description;  // 描述信息
    uint80 private _roundId;      // 轮次 ID：模拟 Chainlink 的数据更新轮次
    uint256 private _timestamp;   // 数据更新的时间戳
    
    constructor() {
        _decimals = 0;
        _description = "Mock Rainfall Oracle";
        _roundId = 1;
        _timestamp = block.timestamp;
    }
    
    /// @notice 返回数据的小数位数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    
    /// @notice 返回预言机描述
    function description() external view override returns (string memory) {
        return _description;
    }
    
    /// @notice 模拟版本号
    function version() external pure override returns (uint256) {
        return 1;
    }
    
    /**
     * @notice 获取特定轮次的数据
     * @dev 模拟接口，实际返回的是当前的伪随机降雨量
     */
    function getRoundData(uint80) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    
    /**
     * @notice 获取最新的数据（这是业务合约最常用的函数）
     * @return roundId 轮次ID
     * @return answer 降雨量（0-100mm）
     * @return startedAt 开始时间
     * @return updatedAt 更新时间
     * @return answeredInRound 在哪一轮完成回答
     */
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    
    /**
     * @dev 内部函数：模拟降雨量数据生成
     * 使用哈希算法生成 0-100 之间的伪随机数
     */
    function _rainfall() private view returns (int256) {
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,    // 当前时间
            block.prevrandao,   // 以太坊合并（Merge）后的随机性源（原 block.difficulty）
            msg.sender          // 调用者地址
        )));
        return int256(pseudoRandom % 101);  // 取模 101，得到 0 到 100 的整数
    }
    
    /**
     * @notice 手动更新数据状态
     * @dev 在测试脚本中调用此函数，可以模拟新的一轮数据产生，改变时间戳和轮次
     */
    function updateData() external {
        _roundId++;
        _timestamp = block.timestamp;
    }
}