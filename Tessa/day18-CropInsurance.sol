// 农民保险系统：农民买保险——如果没下够雨就赔钱
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {    //有老板（可以提钱）
    AggregatorV3Interface private weatherOracle;    //天气数据（刚才那个合约）
    AggregatorV3Interface private ethUsdPriceFeed;   //ETH价格（如1ETH=3000美元）

    uint256 public constant RAINFALL_THRESHOLD = 500;    //常量：少于500mm就赔钱
    uint256 public constant INSURANCE_PREMIUM_USD = 10;   //买保险要10美元
    uint256 public constant INSURANCE_PAYOUT_USD = 50;    //赔50美元

    mapping(address => bool) public hasInsurance;   //记录数据：谁买了保险
    mapping(address => uint256) public lastClaimTimestamp;   //记录数据：上次领钱时间 

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    // 构造函数：创建合约时必须给两个地址
    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);    //天气合约地址
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);    //ETH价格合约地址
    }

    // 买保险:用户要付ETH
    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();    //获取ETH价格
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;    //把美元换算成ETH

        require(msg.value >= premiumInEth, "Insufficient premium amount");   //钱不够→不让买
        require(!hasInsurance[msg.sender], "Already insured");    //检查你是否已买保险

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    // 检查天气+赔钱
    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");   //检查资格：必须买过保险
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");   //24小时候才能再领，防止一直薅钱

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();    //获取天气：调用“天气机器”——今天下了多少雨

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);

        if (currentRainfall < RAINFALL_THRESHOLD) {    //判断是否赔钱：如果雨太少，触发赔钱
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;   //发钱：算出要赔多少ETH

            (bool success, ) = msg.sender.call{value: payoutInEth}("");   //给用户打钱
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    // 获取ETH价格：从Chainlink获取ETH/USD
    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    // 老板提款：只有老板能提走合约的钱
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}


// 整个系统：天气Oracle提供雨量；保险合约判断要不要赔钱；农民收钱or不收钱