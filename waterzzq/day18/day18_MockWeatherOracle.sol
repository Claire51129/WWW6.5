// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入预言机接口和权限控制
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 模拟天气预言机：生成随机降雨量
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0;
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // --- 必须实现的预言机接口 ---
    function decimals() external view override returns (uint8) { return _decimals; }
    function description() external view override returns (string memory) { return _description; }
    function version() external pure override returns (uint256) { return 1; }

    function getRoundData(uint80 _roundId)
        external view override returns (uint80, int256, uint256, uint256, uint80)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    function latestRoundData()
        external view override returns (uint80, int256, uint256, uint256, uint80)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // --- 生成随机降雨量 ---
    function _rainfall() public view returns (int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase, blocksSinceLastUpdate))) % 1000;
        return int256(randomFactor);
    }

    // --- 管理员更新天气数据 ---
    function updateRandomRainfall() external onlyOwner {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }
}