// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
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
    
    // 模拟降雨量数据 (0-100mm)
    function _rainfall() private view returns (int256) {
        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,   //把block.difficulty换成 了block.prevrandao；原因：Solidity 0.8.0 之后，以太坊把block.difficulty（区块难度）改名叫block.prevrandao了，老名字会提示警告；
            msg.sender
        )));
        return int256(pseudoRandom % 101);  // 0-100mm
    }
    
    // 手动更新数据 (用于测试)
    function updateData() external {
        _roundId++;
        _timestamp = block.timestamp;
    }
}