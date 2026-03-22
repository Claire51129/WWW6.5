
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//创建了一个虚假的天气数据预言机，其作用类似于 Chainlink 数据馈送

//AggregatorV3Interface: 这是 Chainlink 的标准预言机接口——在我们的例子中模拟降雨等数据
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//Ownable: OpenZeppelin 的一个助手，它为我们提供了所有权功能——包括owner()和onlyOwner 修饰符
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    uint8 private _decimals;//定义数据的精度
    string private _description;//Feed 的文字标签（如名称）
    uint80 private _roundId;//用于模拟不同的数据更新周期
    uint256 private _timestamp;//记录上次更新发生的时间
    uint256 private _lastUpdateBlock;//跟踪上次更新发生时的块，用于添加随机性
//首次部署合约时设置初始值
    constructor() Ownable(msg.sender) {
        _decimals = 0; // Rainfall in whole millimeters
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;//存储当前时间/区块以模拟数据的新鲜度
    }
//外部应用程序重新定义的小数位数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
//提供人类可读的源描述
    function description() external view override returns (string memory) {
        return _description;
    }
//bn
    function version() external pure override returns (uint256) {
        return 1;
    }
//返回用户请求的某个轮次的数据，支持查询历史，但是事实上无论你查询哪一轮（_roundId_），它都返回同一个最新的数据（由 _rainfall() 决定）和同一个时间（由 _timestamp 决定）
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }
//返回当前获取最新轮次的数据
    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // Function to get current rainfall with random variation
    //每次调用此函数时，都会得到一个新的伪随机降雨值——介于 0 到 999mm 之间
    function _rainfall() public view returns (int256) {
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
    }

    // Function to update random rainfall
    //- 增加轮数（模拟新数据），记录新数据的创建时间
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // Function to force update rainfall (anyone can call)
    //调用的 public 函数来更新“预言机”数据
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}

