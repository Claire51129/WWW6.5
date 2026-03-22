//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private constant _DECIMALS = 0;
    string private constant _DESCRIPTION = "MOCK/RAINFALL/USD";
    uint80 private _roundId;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    function decimals() external pure override returns(uint8) {
        return _DECIMALS;
    }

    function description() external pure override returns(string memory) {
        return _DESCRIPTION;
    }

    function version() external pure override  returns(uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId_) external view override returns(
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return(
            _roundId_,
            _rainfall(),
            _timestamp,
            _timestamp,
            _roundId_
        );
    }

    function latestRoundData() external view override returns(
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return(
            _roundId,
            _rainfall(),
            _timestamp,
            _timestamp,
            _roundId
        );
    }

    function _rainfall() internal view returns(int256) {
        uint256 blockSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blockSinceLastUpdate
        ))) %1000;
        return int256(randomFactor);
    }

    function _updateRandomRainfall() private {
        unchecked {
            _roundId++;
        }
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}
