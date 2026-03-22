//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
  uint8 private _decimals;
  string private _description;
  uint80 private _roundId;
  uint256 private _timestamp;
  uint256 private _lastUpdateBlock;

  constructor() Ownable(msg.sender) {
    _decimals = 0; // e.g., rainfall in millimeters
    _description = "MOCK/RAINFALL/USD";
    _roundId = 0;
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

  function getRoundData(uint80 _roundId) external view override returns (
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

  //function to get the current rainfall value with random variation
  function _rainfall() public view returns (int256) {
    //use block information to generate pseudo-random rainfall data
    uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
    uint256 randomFactor = uint256(keccak256(abi.encodePacked(
      block.timestamp,
      block.coinbase,
      blocksSinceLastUpdate
    ))) % 1000; //random rainfall between 0 and 999 mm

    //return the random rainfall value
    return int256(randomFactor);
  }

  //function to update random rainfall
  function _updateRandomRainfall() private {
    _roundId++;
    _timestamp = block.timestamp;
    _lastUpdateBlock = block.number;
  }

  //function to force update the rainfall data
  function updateRandomRainfall() external {
    _updateRandomRainfall();
  }
}

