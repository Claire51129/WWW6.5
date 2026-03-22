
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    AggregatorV3Interface private weatherOracle;
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    mapping(address => bool) public hasInsurance;
    mapping(address => uint256) public lastClaimTimestamp;

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);
/**

address _weatherOracle: 这是我们的降雨预言机的地址
address _ethUsdPriceFeed: 这是 Chainlink 价格馈送的地址，可为我们提供 ETH → USD 的转换

**/
//保存两个预言机地址以供以后的函数使用

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }
/**
external payable:该函数可以直接从用户那里接收 ETH

**/
    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();//使用 Chainlink 获取 ETH 的当前美元价格
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");//防止用户两次购买保险。

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    function checkRainfallAndClaim() external {
        // 功能仅适用于受保用户
        require(hasInsurance[msg.sender], "No active insurance");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();//从我们的天气预言机中提取最新的降雨数据

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");
// 基本检查以确保预言机数据是最新且有效的
        uint256 currentRainfall = uint256(rainfall);//将降雨量转换为无符号格式
        emit RainfallChecked(msg.sender, currentRainfall);

        if (currentRainfall < RAINFALL_THRESHOLD) {
            //如果降雨量低于干旱阈值，索赔流程将继续进行
            lastClaimTimestamp[msg.sender] = block.timestamp;//记录时间以防止背靠背索赔
            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;
// 使用实时汇率将 50 美元的支出转换为 ETH
            (bool success, ) = msg.sender.call{value: payoutInEth}("");//将 ETH 转移给农民
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }
/**
- 此功能与 **Chainlink** 对话，它为我们提供了**以美元计价的最新 ETH 价格**。
- 它返回的 `price` 并不是直接的实际价值——它带有**8 位额外的数字**。
**/
    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }
//让任何人都可以查看当前降雨量——对仪表板或浏览器很有用
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }
//让合约所有者提取所有收集的 ETH（例如，未使用的溢价
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
//该函数允许合约无需调用函数接收 ETH
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

