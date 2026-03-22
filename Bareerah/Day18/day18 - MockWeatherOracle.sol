// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// AggregatorV3Interface 是 Chainlink 标准预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 模拟预言机
contract MockWeatherOracle is AggregatorV3Interface, Ownable{
    
    // 定义数据精度
    uint8 private _decimals;

    // Feed 文字标签
    string private _description;
    
    // 模拟不同数据更新周期
    uint80 private _roundId;

    // 记录上次更新发生的时间
    uint256 private _timestamp;

    // 跟踪上次更新发生时的块，用于添加随机性
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender){
        _decimals = 0;
        _description = "MOCK/RAINFALL/USD";

        // 从第一轮开始
        _roundId = 1;

        //存储当前时间 / 区块以模拟数据新鲜度
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // Chainlink 接口函数
    function decimals() external view override returns(uint8){
        return _decimals;
    }

    function description() external view override returns (string memory){
        return _description;
    }

    function version() external pure override returns(uint256){
        return 1;
    }

    // 舍入数据函数
    // 模拟 Chainlink 访问历史数据的标准功能
    function getRoundData(uint80 _roundId_) external view override returns(uint80 roundId, int256 answer, uint256 startedAt, uint256 updateAt, uint80 answeredInRound){
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // 应用用于获取最新数据
    function latestRoundData() external view override returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updateAt, uint80 answeredInRound){
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 模拟降雨发生器
    function _rainfall() public view returns(int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase, blocksSinceLastUpdate))) % 1000;

        return int256(randomFactor);
    }

    // 辅助函数，增加轮数（模拟新数据）和记录新数据创建时间
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // 用于更新预言机数据
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}