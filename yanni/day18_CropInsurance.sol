// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Chainlink 价格预言机接口（用于获取天气数据 & ETH价格）
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// OpenZeppelin 的权限控制（onlyOwner）
import "@openzeppelin/contracts/access/Ownable.sol";

// 农作物保险合约
contract CropInsurance is Ownable {

    // 天气预言机（例如降雨量数据）
    AggregatorV3Interface private weatherOracle;

    // ETH/USD 价格预言机
    AggregatorV3Interface private ethUsdPriceFeed;

    // 降雨阈值（低于这个值可以理赔）
    uint256 public constant RAINFALL_THRESHOLD = 500;

    // 保费（单位：USD）
    uint256 public constant INSURANCE_PREMIUM_USD = 10;

    // 理赔金额（单位：USD）
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    // 用户是否已经购买保险
    mapping(address => bool) public hasInsurance;

    // 用户上一次理赔时间（用于限制频率）
    mapping(address => uint256) public lastClaimTimestamp;

    // 购买保险事件
    event InsurancePurchased(address indexed farmer, uint256 amount);

    // 提交理赔事件
    event ClaimSubmitted(address indexed farmer);

    // 理赔成功事件
    event ClaimPaid(address indexed farmer, uint256 amount);

    // 查询降雨事件
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    // 构造函数：初始化预言机地址
    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    // 购买保险（需要支付 ETH）
    function purchaseInsurance() external payable {

        // 获取 ETH/USD 价格
        uint256 ethPrice = getEthPrice();

        // 把 USD 保费换算成 ETH（单位：wei）
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;

        // 检查支付金额是否足够
        require(msg.value >= premiumInEth, "Insufficient premium amount");

        // 防止重复购买
        require(!hasInsurance[msg.sender], "Already insured");

        // 标记用户已购买保险
        hasInsurance[msg.sender] = true;

        emit InsurancePurchased(msg.sender, msg.value);
    }

    // 检查降雨并尝试理赔
    function checkRainfallAndClaim() external {

        // 必须已经购买保险
        require(hasInsurance[msg.sender], "No active insurance");

        // 限制 24 小时内只能理赔一次
        require(
            block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days,
            "Must wait 24h between claims"
        );

        // 从预言机获取降雨数据
        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();

        // 确保数据有效
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);

        emit RainfallChecked(msg.sender, currentRainfall);

        // 如果降雨量低于阈值，触发理赔
        if (currentRainfall < RAINFALL_THRESHOLD) {

            // 更新理赔时间（防止重复领取）
            lastClaimTimestamp[msg.sender] = block.timestamp;

            emit ClaimSubmitted(msg.sender);

            // 计算赔付金额（USD → ETH）
            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;

            // 向用户转账
            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    // 获取 ETH/USD 价格
    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    // 获取当前降雨量
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }

    // 提取合约余额（仅管理员）
    function withdraw() external onlyOwner {

        // 将合约中的所有 ETH 转给 owner
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    // 接收 ETH（允许合约直接收款）
    receive() external payable {}

    // 查询合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}