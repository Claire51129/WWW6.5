// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 导入 Chainlink 预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 导入 OpenZeppelin 的 Ownable 合约
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * CropInsurance
 * 农作物保险智能合约
 *
 * 功能：
 * 1 农民购买保险
 * 2 读取天气预言机降雨数据
 * 3 如果降雨低于阈值自动理赔
 */
contract CropInsurance is Ownable {

    // 天气预言机
    AggregatorV3Interface private weatherOracle;

    // ETH/USD 价格预言机
    AggregatorV3Interface private ethUsdPriceFeed;

    // 降雨阈值（毫米）
    uint256 public constant RAINFALL_THRESHOLD = 500;

    // 保费（美元）
    uint256 public constant INSURANCE_PREMIUM_USD = 10;

    // 理赔金额（美元）
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    // 记录用户是否购买保险
    mapping(address => bool) public hasInsurance;

    // 记录用户最后一次理赔时间
    mapping(address => uint256) public lastClaimTimestamp;

    // 事件：购买保险
    event InsurancePurchased(address indexed farmer, uint256 amount);

    // 事件：提交理赔
    event ClaimSubmitted(address indexed farmer);

    // 事件：理赔成功
    event ClaimPaid(address indexed farmer, uint256 amount);

    // 事件：降雨量查询
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    /*
     * 构造函数
     * 初始化两个预言机地址
     */
    constructor(address _weatherOracle, address _ethUsdPriceFeed)
        payable
        Ownable(msg.sender)
    {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    /*
     * 购买保险
     * 用户发送 ETH 作为保费
     */
    function purchaseInsurance() external payable {

        // 获取 ETH 当前价格
        uint256 ethPrice = getEthPrice();

        // 将 10 美元转换为 ETH
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;

        // 检查用户发送的 ETH 是否足够
        require(msg.value >= premiumInEth, "Insufficient premium amount");

        // 防止重复购买
        require(!hasInsurance[msg.sender], "Already insured");

        // 标记用户为已投保
        hasInsurance[msg.sender] = true;

        emit InsurancePurchased(msg.sender, msg.value);
    }

    /*
     * 检查降雨并触发理赔
     */
    function checkRainfallAndClaim() external {

        // 必须已购买保险
        require(hasInsurance[msg.sender], "No active insurance");

        // 每次理赔必须间隔 24 小时
        require(
            block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days,
            "Must wait 24h between claims"
        );

        // 从天气预言机获取降雨数据
        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();

        // 检查数据是否有效
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);

        emit RainfallChecked(msg.sender, currentRainfall);

        // 如果降雨量低于阈值则赔付
        if (currentRainfall < RAINFALL_THRESHOLD) {

            // 记录理赔时间
            lastClaimTimestamp[msg.sender] = block.timestamp;

            emit ClaimSubmitted(msg.sender);

            // 获取 ETH 当前价格
            uint256 ethPrice = getEthPrice();

            // 计算 50 美元等值 ETH
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;

            // 使用 call 发送 ETH（推荐方式）
            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    /*
     * 获取 ETH 价格
     * 来自 Chainlink ETH/USD 价格预言机
     */
    function getEthPrice() public view returns (uint256) {
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        return uint256(price);
    }

    /*
     * 获取当前降雨量
     */
    function getCurrentRainfall() public view returns (uint256) {
        (, int256 rainfall,,,) = weatherOracle.latestRoundData();
        return uint256(rainfall);
    }

    /*
     * 管理员提取合约余额
     * 使用 call 代替 transfer（Solidity 推荐）
     */
    function withdraw() external onlyOwner {

        // 获取合约余额
        uint256 balance = address(this).balance;

        // 使用 call 发送 ETH
        (bool success, ) = payable(owner()).call{value: balance}("");

        require(success, "Withdrawal failed");
    }

    // 允许直接向合约发送 ETH
    receive() external payable {}

    /*
     * 查询合约当前余额
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
