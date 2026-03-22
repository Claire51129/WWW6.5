// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day18_AggregatorV3Interface.sol";

contract MockWeatherOracle is AggregatorV3Interface {

    address public owner;
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    bool public manualMode;
    int256 public manualRainfall;

    event RainfallUpdated(uint80 roundId, int256 rainfall, bool isManual);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _decimals = 0;
        _description = "MOCK/RAINFALL/MM";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
        manualMode = false;
    }

    function decimals() external view override returns (uint8) { return _decimals; }
    function description() external view override returns (string memory) { return _description; }
    function version() external pure override returns (uint256) { return 1; }

    function getRoundData(uint80 _rid) external view override returns (
        uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound
    ) {
        return (_rid, _currentRainfall(), _timestamp, _timestamp, _rid);
    }

    function latestRoundData() external view override returns (
        uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound
    ) {
        return (_roundId, _currentRainfall(), _timestamp, _timestamp, _roundId);
    }

    function _currentRainfall() internal view returns (int256) {
        if (manualMode) return manualRainfall;
        return _pseudoRandomRainfall();
    }

    function _pseudoRandomRainfall() internal view returns (int256) {
        uint256 blocks = block.number - _lastUpdateBlock;
        uint256 rand = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocks
        ))) % 1000;
        return int256(rand);
    }

    function setManualRainfall(int256 _rainfall) external onlyOwner {
        require(_rainfall >= 0, "Rainfall cannot be negative");
        manualRainfall = _rainfall;
        manualMode = true;
        _advance();
        emit RainfallUpdated(_roundId, _rainfall, true);
    }

    function setAutoMode() external onlyOwner {
        manualMode = false;
        _advance();
        emit RainfallUpdated(_roundId, _pseudoRandomRainfall(), false);
    }

    function advanceRound() external {
        _advance();
        emit RainfallUpdated(_roundId, _currentRainfall(), manualMode);
    }

    function _advance() internal {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }
}
