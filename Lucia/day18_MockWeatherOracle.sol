// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable{
    //is Ownable继承，获取现成的功能；virtual允许子合约override来重写它
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

    function decimals() external view override returns (uint8){
        return _decimals;//override 写上具体逻辑替换掉父类里的那个空壳子
    }

    function description() external view override returns(string memory){
        return _description;
    }

    function version() external pure override returns(uint256){
        return 1;
    }

    function getRoundData(uint80 _roundId_)
    external view override returns(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answerInRound)
    {//int代表Integer有符号整数，可以是负数
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);

    }

    function latestRoundData()
    external view override returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {//uint80 占用80位bit，chainlink预言机的标准
        return(_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    //()代表_rainfall()执行调用这个函数，rainfall调用时返回值也需要是int256
    }

    function _rainfall()public view returns (int256){
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            //keccak哈希运算
            block.timestamp,
            block.coinbase,//验证者/矿工地址,谁拿到了小费
            blocksSinceLastUpdate
        )))%1000;//取余运算，任何大数字除以1000，余数一定在0到999之间
        return int256(randomFactor);
        }

        function _updateRandomRainfall() private{
            _roundId++;
            _timestamp = block.timestamp;
            _lastUpdateBlock = block.number;
        }

        function updateRandomRainfall() external{
            _updateRandomRainfall();
        }
    }
