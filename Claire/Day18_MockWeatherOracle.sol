// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.19;
// 指定Solidity编译器版本为0.8.19及以上

// 手动定义 Chainlink 接口（替代 import）
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

import "@openzeppelin/contracts/access/Ownable.sol";
// 导入 OpenZeppelin 的所有权管理合约
// 提供 onlyOwner 修饰符，只有合约所有者能调用某些函数

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
// 定义一个合约，叫"模拟天气预言机"
// is AggregatorV3Interface：实现 Chainlink 预言机接口
// is Ownable：继承所有权管理功能

    uint8 private _decimals;
    // 小数位数（私有变量）
    // 这里设为0，表示降雨量用整数毫米表示
    // 例如：5 表示 5mm 降雨

    string private _description;
    // 数据描述（私有变量）
    // 说明这个预言机提供什么数据

    uint80 private _roundId;
    // 轮次ID（私有变量）
    // 每次数据更新，roundId 会递增

    uint256 private _timestamp;
    // 时间戳（私有变量）
    // 记录数据最后一次更新的时间

    uint256 private _lastUpdateBlock;
    // 最后更新的区块号（私有变量）
    // 用于生成随机数

    constructor() Ownable(msg.sender) {
    // 构造函数：部署时自动执行
    // Ownable(msg.sender)：设置合约所有者为部署者
        
        _decimals = 0; // Rainfall in whole millimeters
        // 小数位数为0，降雨量用整数毫米表示
        
        _description = "MOCK/RAINFALL/USD";
        // 数据描述：模拟降雨量数据
        
        _roundId = 1;
        // 初始轮次ID为1
        
        _timestamp = block.timestamp;
        // 记录部署时的时间戳
        
        _lastUpdateBlock = block.number;
        // 记录部署时的区块号
    }

    function decimals() external view override returns (uint8) {
    // 函数：返回小数位数
    // override：重写接口中的函数
    // 实现 AggregatorV3Interface 接口要求
        
        return _decimals;
        // 返回0，表示整数
    }

    function description() external view override returns (string memory) {
    // 函数：返回数据描述
    // 实现 AggregatorV3Interface 接口要求
        
        return _description;
        // 返回 "MOCK/RAINFALL/USD"
    }

    function version() external pure override returns (uint256) {
    // 函数：返回合约版本
    // pure：不读也不写链上数据
        
        return 1;
        // 版本号为1
    }

    function getRoundData(uint80 _roundId_)
    // 函数：获取指定轮次的数据
    // uint80 _roundId_：要查询的轮次ID
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
        // 返回5个值：
        // roundId：轮次ID
        // answer：数据值（降雨量）
        // startedAt：开始时间
        // updatedAt：更新时间
        // answeredInRound：在哪一轮被回答
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
        // 返回查询的轮次ID、当前降雨量、时间戳、时间戳、查询的轮次ID
        // 注意：模拟版本所有轮次都返回当前降雨量
    }

    function latestRoundData()
    // 函数：获取最新一轮的数据
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
        // 返回最新数据
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
        // 返回当前轮次ID、当前降雨量、时间戳、时间戳、当前轮次ID
    }

    // Function to get current rainfall with random variation
    function _rainfall() public view returns (int256) {
    // 函数：获取当前降雨量（带随机变化）
    // public view：公开的只读函数
        
        // Use block information to generate pseudo-random variation
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        // 计算距离上次更新过了多少个区块
        // 区块号差值
        
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999
        // 生成伪随机数（0-999）
        // keccak256：哈希函数，把输入变成随机数
        // abi.encodePacked：把多个参数打包
        // block.timestamp：当前时间戳
        // block.coinbase：当前矿工地址
        // blocksSinceLastUpdate：区块差值
        // % 1000：取余，得到0-999之间的数

        // Return random rainfall between 0 and 999mm
        return int256(randomFactor);
        // 返回0-999之间的降雨量（毫米）
    }

    // Function to update random rainfall
    function _updateRandomRainfall() private {
    // 函数：更新随机降雨量（私有函数）
        
        _roundId++;
        // 轮次ID加1
        
        _timestamp = block.timestamp;
        // 更新时间戳为当前时间
        
        _lastUpdateBlock = block.number;
        // 更新区块号为当前区块
    }

    // Function to force update rainfall (anyone can call)
    function updateRandomRainfall() external {
    // 函数：强制更新降雨量（任何人都可以调用）
    // external：只能外部调用
        
        _updateRandomRainfall();
        // 调用私有更新函数
    }
}