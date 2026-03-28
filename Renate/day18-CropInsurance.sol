// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Chainlink 预言机接口定义 - 直接内联，无需外部依赖
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// 简单的所有权管理合约 - 直接内联，无需外部依赖
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

// CropInsurance - 农作物保险合约（升级版）
// 这是一个参数保险合约，使用 Chainlink 预言机获取降雨量和 ETH/USD 价格
// 当降雨量低于阈值时，自动向投保农民赔付
contract CropInsurance is Ownable {
    // 天气预言机接口，用于获取降雨量数据
    AggregatorV3Interface private weatherOracle;
    // ETH/USD 价格预言机，用于将美元金额转换为 ETH
    AggregatorV3Interface private ethUsdPriceFeed;

    // 常量定义
    uint256 public constant RAINFALL_THRESHOLD = 500;        // 降雨阈值（毫米），低于此值触发赔付
    uint256 public constant INSURANCE_PREMIUM_USD = 10;      // 保险保费（美元）
    uint256 public constant INSURANCE_PAYOUT_USD = 50;       // 保险赔付金额（美元）

    // 存储每个地址的投保状态
    mapping(address => bool) public hasInsurance;
    // 存储每个地址上次索赔的时间戳，用于限制索赔频率
    mapping(address => uint256) public lastClaimTimestamp;

    // 事件定义
    event InsurancePurchased(address indexed farmer, uint256 amount);  // 购买保险事件
    event ClaimSubmitted(address indexed farmer);                      // 提交索赔事件
    event ClaimPaid(address indexed farmer, uint256 amount);           // 赔付完成事件
    event RainfallChecked(address indexed farmer, uint256 rainfall);   // 检查降雨量事件

    // 构造函数
    // _weatherOracle: 天气预言机合约地址
    // _ethUsdPriceFeed: ETH/USD 价格预言机地址
    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    // 购买保险函数
    // 农民支付保费购买保险，保费金额根据当前 ETH 价格动态计算
    function purchaseInsurance() external payable {
        // 获取当前 ETH/USD 价格
        uint256 ethPrice = getEthPrice();
        // 计算保费对应的 ETH 数量
        // 公式: (保费美元 * 1e26) / ETH价格 = 所需ETH数量（wei）
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;

        // 验证支付的 ETH 足够
        require(msg.value >= premiumInEth, "Insufficient premium amount");
        // 验证该地址尚未投保
        require(!hasInsurance[msg.sender], "Already insured");

        // 记录投保状态
        hasInsurance[msg.sender] = true;
        // 触发购买保险事件
        emit InsurancePurchased(msg.sender, msg.value);
    }

    // 检查降雨量并索赔函数
    // 农民调用此函数检查降雨量，如果低于阈值则自动获得赔付
    function checkRainfallAndClaim() external {
        // 验证调用者有有效保险
        require(hasInsurance[msg.sender], "No active insurance");
        // 验证距离上次索赔已超过 24 小时（防止频繁索赔）
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

        // 从天气预言机获取最新降雨量数据
        (
            uint80 roundId,           // 数据轮次ID
            int256 rainfall,          // 降雨量数据
            ,                         // 开始时间（未使用）
            uint256 updatedAt,        // 数据更新时间
            uint80 answeredInRound    // 回答所在轮次
        ) = weatherOracle.latestRoundData();

        // 验证数据有效性
        require(updatedAt > 0, "Round not complete");
        // 验证数据不是过期的（answeredInRound >= roundId 表示数据是最新的）
        require(answeredInRound >= roundId, "Stale data");

        // 将降雨量转换为 uint256
        uint256 currentRainfall = uint256(rainfall);
        // 触发检查降雨量事件
        emit RainfallChecked(msg.sender, currentRainfall);

        // 判断降雨量是否低于阈值（干旱条件）
        if (currentRainfall < RAINFALL_THRESHOLD) {
            // 更新上次索赔时间戳
            lastClaimTimestamp[msg.sender] = block.timestamp;
            // 触发提交索赔事件
            emit ClaimSubmitted(msg.sender);

            // 获取当前 ETH/USD 价格
            uint256 ethPrice = getEthPrice();
            // 计算赔付金额对应的 ETH 数量
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;

            // 执行赔付转账
            // 使用 call{value: amount}("") 发送 ETH，更灵活且兼容性好
            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");

            // 触发赔付完成事件
            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    // 获取 ETH/USD 价格函数
    // 从 Chainlink 价格预言机获取当前 ETH 价格
    // 返回: ETH 价格（美元），精度为 8 位小数（即 $3000.00 = 300000000000）
    function getEthPrice() public view returns (uint256) {
        (
            ,                 // roundId（未使用）
            int256 price,     // ETH/USD 价格
            ,                 // startedAt（未使用）
            ,                 // updatedAt（未使用）
                              // answeredInRound（未使用）
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    // 获取当前降雨量函数
    // 从天气预言机获取最新降雨量数据
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,                 // roundId（未使用）
            int256 rainfall,  // 降雨量数据
            ,                 // startedAt（未使用）
            ,                 // updatedAt（未使用）
                              // answeredInRound（未使用）
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }

    // 提取合约余额（仅合约所有者）
    // 用于合约所有者提取合约中的 ETH
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // 接收 ETH 函数
    // 允许合约接收 ETH，用于向保险池充值
    receive() external payable {}

    // 获取合约余额函数
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// 合约设计要点说明:
//
// 1. 双预言机设计:
//    - weatherOracle: 获取降雨量数据
//    - ethUsdPriceFeed: 获取 ETH/USD 价格，实现美元计价、ETH 支付
//
// 2. 价格转换计算:
//    - 保费和赔付金额以美元计价
//    - 根据实时 ETH 价格转换为 ETH 数量
//    - 公式: ethAmount = (usdAmount * 1e26) / ethPrice
//
// 3. 安全措施:
//    - 24 小时索赔冷却期，防止频繁索赔
//    - 预言机数据新鲜度检查（answeredInRound >= roundId）
//    - 使用 Ownable 管理合约所有权
//
// 4. 事件日志:
//    - 记录所有关键操作，便于前端监听和链下分析
//
// 5. 使用场景:
//    - 农民购买保险，支付 ETH 作为保费
//    - 干旱发生时（降雨量 < 500mm），自动获得 ETH 赔付
//    - 赔付金额根据实时 ETH 价格动态计算
