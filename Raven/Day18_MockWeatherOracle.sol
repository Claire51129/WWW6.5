// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import "https://raw.githubusercontent.com/smartcontractkit/chainlink/refs/tags/contracts-v1.3.0/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
	uint8 private _decimals;
	string private _description;
	uint80 private _roundId;
	uint256 private _timestamp;
	uint256 private _lastUpdateBlock;
	constructor() Ownable(msg.sender) {
		_decimals = 0; // Rainfall in whole millimeters
		_description = "MOCK/RAINFALL/USD";
		_roundId = 1;
		_timestamp = block.timestamp;
		_lastUpdateBlock = block.number;
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
	// Unused
	function getRoundData(uint80 _roundId_) external view override returns (
		uint80 roundId,
		int256 answer,
		uint256 startedAt,
		uint256 updatedAt,
		uint80 answeredInRound
	){
		return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
	}
	function latestRoundData() external view override returns (
		uint80 roundId,
		int256 answer,
		uint256 startedAt,
		uint256 updatedAt,
		uint80 answeredInRound
	){
		return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
	}
	function _rainfall() public view returns (int256) {
		uint256 blockSinceLastUpdate = block.number - _lastUpdateBlock;
		// Random number between 0 and 999
		uint256 randomFactor = uint256(keccak256(abi.encodePacked(
			block.timestamp,
			block.coinbase,
			blockSinceLastUpdate
		))) % 1000;
		return int256(randomFactor);
	}
	function _updateRandomRainfall() private {
		_roundId++;
		_timestamp = block.timestamp;
		_lastUpdateBlock = block.number;
	}
	// Function to force update rainfall (anyone can call)
	function updateRandomRainfall() external {
		_updateRandomRainfall();
	}
}
