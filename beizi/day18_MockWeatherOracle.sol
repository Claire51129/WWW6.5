//SPDX-License-Identifier:MIT
pragma  solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable{
    uint8 private _decimals;
    string private _discreption;
    uint80 private _roundID;
    uint256 private _timestamp;
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender){
        _decimals = 0; //because the rainfall always integrate
        _discreption = "MOCK/RAINFALL/USD";
        _roundID = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    function decimals() external view override returns(uint8){
        return _decimals;
    }

    function description() external view override returns(string memory){
        return _discreption;
    }

    function version() external pure override returns(uint256){
        return 1;
    }

    //history data
    function getRoundData(uint80 _roundID_) external view override returns(uint80 roundID,int256 answer, uint256 startedAt,uint256 updateAt, uint80 answeredInRound ){
        return (_roundID_, _rainfall(), _timestamp, _timestamp, _roundID) ;
    }

    //core function : lastest data , this function will be call in CropInsurance
    //latestRoundData
    function latestRoundData() external view override returns(uint80 roundID,int256 answer, uint256 startedAt,uint256 updateAt, uint80 answeredInRound ){
        return (_roundID, _rainfall(), _timestamp, _timestamp, _roundID) ;
    } 

    function _rainfall() public view returns(int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(block.timestamp,block.coinbase,blocksSinceLastUpdate))) %1000;

        return int256(randomFactor);
    }

    function _updateRandomRainfall() private {
        _roundID ++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    //in real situation, this function trigered by chainlink
    function updateRandomRainfall() external{
        _updateRandomRainfall();
    }

}
