// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockEthUsdPriceFeed is AggregatorV3Interface {
    int256 private _price;

    constructor(int256 initialPrice) {
        _price = initialPrice; // 比如传入 200000000000 = $2000 (8位decimals)
    }

    function decimals() external pure override returns (uint8) { return 8; }
    function description() external pure override returns (string memory) { return "ETH/USD"; }
    function version() external pure override returns (uint256) { return 1; }

    function latestRoundData() external view override returns (
        uint80, int256, uint256, uint256, uint80
    ) {
        return (1, _price, block.timestamp, block.timestamp, 1);
    }

    function getRoundData(uint80 _roundId) external view override returns (
        uint80, int256, uint256, uint256, uint80
    ) {
        return (_roundId, _price, block.timestamp, block.timestamp, _roundId);
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
    }
}
