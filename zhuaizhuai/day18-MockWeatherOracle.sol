// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId, int256 answer, uint256 startedAt,
        uint256 updatedAt, uint80 answeredInRound
    );
    function latestRoundData() external view returns (
        uint80 roundId, int256 answer, uint256 startedAt,
        uint256 updatedAt, uint80 answeredInRound
    );
    }

// 模拟天气预言机合约
// 实现了AggregatorV3Interface接口 = 格式跟真实Chainlink预言机一样
// 继承了Ownable = 有owner权限管理
contract MockWeatherOracle is AggregatorV3Interface{
    address public owner;
    modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
    }
    
    uint8 private _decimals;          // 小数位数（降雨量用整数，所以是0）
    string private _description;      // 这个预言机的描述
    uint80 private _roundId;          // 当前轮次编号（每次更新+1）
    uint256 private _timestamp;       // 最后更新时间
    uint256 private _lastUpdateBlock; // 最后更新的区块号

    // 部署时初始化所有基本信息
    constructor() {
        _decimals = 0;                      // 降雨量用整数毫米，不需要小数
        _description = "MOCK/RAINFALL/USD"; // 描述：模拟降雨量数据
        _roundId = 1;                       // 从第1轮开始
        _timestamp = block.timestamp;       // 记录部署时间
        _lastUpdateBlock = block.number;    // 记录部署时的区块号
    }

    // 返回小数位数
    // override = 实现接口里规定的函数
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 返回预言机描述
    function description() external view override returns (string memory) {
        return _description;
    }

    // 返回版本号
    function version() external pure override returns (uint256) {
        return 1;
    }

    // 获取某一轮的数据
    // 返回：轮次、降雨量、开始时间、更新时间、答案轮次
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,        // 降雨量数据
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // 获取最新一轮的数据（最常用的函数）
    // 外部合约调用这个函数来获取最新降雨量
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,        // 最新降雨量
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 内部函数：用区块信息生成伪随机降雨量
    function _rainfall() public view returns (int256) {
        
        // 计算距离上次更新过了多少个区块
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        
        // 用区块信息生成伪随机数
        // keccak256 = 哈希函数，把多个值混合成一个随机数
        // abi.encodePacked = 把多个值打包在一起
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,          // 当前时间
            block.coinbase,           // 当前矿工地址
            blocksSinceLastUpdate     // 距离上次更新的区块数
        ))) % 1000; // 取余1000，得到0-999之间的数字
        
        // 返回0-999毫米之间的随机降雨量
        return int256(randomFactor);
    }

    // 私有函数：更新降雨量数据
    // private = 只有合约内部能调用
    function _updateRandomRainfall() private {
        _roundId++;                          // 轮次+1
        _timestamp = block.timestamp;        // 更新时间戳
        _lastUpdateBlock = block.number;     // 更新区块号
    }

    // 公开函数：任何人都可以触发更新降雨量
    // 调用后会产生新的随机降雨量数据
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}
