// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 手动定义 Chainlink 接口
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract MockWeatherOracle is AggregatorV3Interface {
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;
    uint256 private _timestamp;
    
    constructor() {
        _decimals = 0;
        _description = "Mock Rainfall Oracle";
        _roundId = 1;
        _timestamp = block.timestamp;
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
    
    function getRoundData(uint80) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }
    
    function _rainfall() private view returns (int256) {
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender
        )));
        return int256(pseudoRandom % 101);
    }
    
    function updateData() external {
        _roundId++;
        _timestamp = block.timestamp;
    }
}
