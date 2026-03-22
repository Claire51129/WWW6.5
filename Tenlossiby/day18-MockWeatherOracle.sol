// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Chainlink 预言机接口定义 - 直接内联，无需外部依赖
// 这个接口定义与 Chainlink 官方完全一致，确保兼容性
interface AggregatorV3Interface {
    // 获取数据精度（小数位数）
    function decimals() external view returns (uint8);
    // 获取预言机描述信息
    function description() external view returns (string memory);
    // 获取预言机版本号
    function version() external view returns (uint256);
    // 获取指定轮次的数据
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    // 获取最新轮次的数据（最常用的函数）
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// 简单的所有权管理合约 - 直接内联，无需外部依赖
// 实现了基本的访问控制功能，只有合约所有者能执行特定操作
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// MockWeatherOracle - 模拟天气预言机合约（升级版）
// 实现了 Chainlink 的 AggregatorV3Interface 接口
// 用于开发和测试环境，模拟真实的天气数据预言机
// 生成伪随机的降雨量数据，模拟真实世界的天气变化
contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    // 数据精度（小数位数）
    // 降雨量使用整数表示，精度为 0（整毫米）
    uint8 private _decimals;
    // 预言机描述信息
    string private _description;
    // 数据轮次 ID，每次更新时递增
    uint80 private _roundId;
    // 数据更新时间戳
    uint256 private _timestamp;
    // 上次更新时的区块号
    uint256 private _lastUpdateBlock;

    // 构造函数 - 初始化预言机参数
    constructor() Ownable(msg.sender) {
        _decimals = 0; // 降雨量以整毫米为单位，无小数
        _description = "MOCK/RAINFALL/USD"; // 描述：模拟降雨量数据
        _roundId = 1; // 初始轮次 ID
        _timestamp = block.timestamp; // 当前区块时间戳
        _lastUpdateBlock = block.number; // 当前区块号
    }

    // 获取数据精度（小数位数）
    // 返回: 0，表示降雨量使用整数毫米
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 获取预言机描述信息
    // 返回: "MOCK/RAINFALL/USD"
    function description() external view override returns (string memory) {
        return _description;
    }

    // 获取预言机版本号
    // 返回: 1（当前版本）
    function version() external pure override returns (uint256) {
        return 1;
    }

    // 获取指定轮次的数据
    // _roundId_: 要查询的轮次 ID
    // 返回: (roundId, answer, startedAt, updatedAt, answeredInRound)
    function getRoundData(uint80 _roundId_)
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        // 返回请求的轮次 ID 和当前计算的降雨量
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // 获取最新轮次的数据（AggregatorV3Interface 标准函数）
    // 这是使用最频繁的函数，获取最新的降雨量数据
    // 返回:
    //   roundId: 当前数据轮次 ID
    //   answer: 当前降雨量（毫米）
    //   startedAt: 轮次开始时间戳
    //   updatedAt: 数据更新时间戳
    //   answeredInRound: 回答所在的轮次
    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        // 返回当前轮次 ID 和计算的降雨量
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // 计算当前降雨量（内部函数）
    // 使用区块信息生成伪随机数，模拟降雨量变化
    // 返回: 0-999 之间的随机整数（毫米）
    function _rainfall() public view returns (int256) {
        // 计算距离上次更新的区块数
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;

        // 使用区块信息生成伪随机数
        // 使用 keccak256 哈希多个区块参数，增加随机性
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,      // 当前区块时间戳
            block.coinbase,       // 矿工地址
            blocksSinceLastUpdate // 距离上次更新的区块数
        ))) % 1000; // 取模 1000，得到 0-999 之间的数

        // 返回随机降雨量（0-999 毫米）
        return int256(randomFactor);
    }

    // 更新降雨量数据（内部函数）
    // 递增轮次 ID，更新时间戳和区块号
    function _updateRandomRainfall() private {
        _roundId++; // 递增轮次 ID
        _timestamp = block.timestamp; // 更新为当前时间戳
        _lastUpdateBlock = block.number; // 更新为当前区块号
    }

    // 强制更新降雨量（外部函数，任何人可调用）
    // 调用此函数会触发数据更新，生成新的随机降雨量
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}

// 合约设计要点说明:
//
// 1. Chainlink 兼容性:
//    - 实现 AggregatorV3Interface 接口，与真实 Chainlink 预言机接口一致
//    - 支持 latestRoundData() 和 getRoundData() 标准函数
//    - 可被任何支持 Chainlink 的合约直接使用
//
// 2. 伪随机数生成:
//    - 使用区块参数生成伪随机数
//    - 注意: 这不是真正安全的随机数，仅用于测试
//    - 生产环境应使用 Chainlink VRF 获取安全随机数
//
// 3. 数据更新机制:
//    - 每次调用 updateRandomRainfall() 会更新轮次
//    - _rainfall() 函数根据区块信息实时计算
//    - 即使不更新，每次查询也会得到不同结果
//
// 4. 使用场景:
//    - 开发和测试环境模拟天气数据
//    - 演示参数保险合约的工作原理
//    - 本地测试无需连接真实 Chainlink 网络
//
// 5. 与真实预言机的区别:
//    - 真实预言机: 由去中心化网络提供真实数据
//    - 模拟预言机: 本地生成伪随机数据，仅用于测试
