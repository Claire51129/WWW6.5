// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Chainlink定义好的接口 规定了一个oracle合约应该有哪些函数
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;
    string private _description;
    uint80 private _roundId;//第几轮数据更新
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0; //整数
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

    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);

    }


    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);

    }

    //生成随机数
    function _rainfall() public view returns (int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // 0-999的随机数

        return int256(randomFactor);

    }

    //模拟数据更新
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;

    }

    // 给外部调用的更新函数
    function updateRandomRainfall() external {
        _updateRandomRainfall();

    }

}

