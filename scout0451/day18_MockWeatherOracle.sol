
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//Chainlink 的标准预言机接口,用于获取价格信息或在我们的例子中模拟降雨等数据。
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//提供所有权功能
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;       //定义数据精度，降雨量以整数毫米为单位
    string private _description;   //文字标签
    uint80 private _roundId;       //模拟不同的数据更新周期
    uint256 private _timestamp;    //上次更新发生的时间
    uint256 private _lastUpdateBlock;  //跟踪上次更新发生时的块，用于添加随机性

    constructor() Ownable(msg.sender) {
        _decimals = 0; // Rainfall in whole millimeters
        _description = "MOCK/RAINFALL/USD"; //可读标签：模拟/降雨量/美元
        _roundId = 1;  //从第1轮开始           
        _timestamp = block.timestamp;  //储存当前时间
        _lastUpdateBlock = block.number; //储存当前区块
    }

    //返回应用程序预期的小数位数：0
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    //提供人类可读的标签
    function description() external view override returns (string memory) {
        return _description;
    }

    //信息性；模拟的版本1
    function version() external pure override returns (uint256) {
        return 1;
    }

    //模拟了 Chainlink 访问历史数据的标准功能
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        //返回轮次、模拟降雨量值、两次相同时间戳
        //真正的预言机中，startedAt 和 updatedAt可能不同。这里简化它
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    //获取最新数据
    function latestRoundData()
        external
        view
        override
        //返回当前轮次、随机降雨量值、时间戳、确认轮次
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // Function to get current rainfall with random variation
    function _rainfall() public view returns (int256) {
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock; //计算自上次更新以来经过的区块数
        uint256 randomFactor = uint256(  //把 keccak256 输出的 32 字节哈希值强制转换为 256 位无符号整数
            keccak256(       //以太坊生态中最常用的哈希函数，输入任意长度数据，输出32字节哈希值
            abi.encodePacked( //把多个不同类型的输入打包成一串连续的字节数据
            block.timestamp,  //区块时间戳
            block.coinbase,   //矿工地址
            blocksSinceLastUpdate  //上次更新以来经过的区块数
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
    }

    // Function to update random rainfall
    function _updateRandomRainfall() private {
        _roundId++;                      //增加轮数
        _timestamp = block.timestamp;    //新数据时间戳
        _lastUpdateBlock = block.number; //新区块数
    }

    //任何人都可以调用的 public 函数来更新“预言机”数据
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}


//使用它代替真正的 Chainlink 预言机来测试保险、游戏或任何对降雨做出反应的逻辑
