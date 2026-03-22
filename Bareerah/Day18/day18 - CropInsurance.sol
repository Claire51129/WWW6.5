// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable{
    AggregatorV3Interface private weatherOracle;
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    mapping (address => bool) public hasInsurance;
    mapping (address => uint256) public lastClaimTimestamp;

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender){
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable{
        // 使用 Chainlink 获取 ETH 当前美元价格
        uint256 ethPrice = getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    // 仅用于受保用户
    function checkRainfallAndClaim() external{
        require(hasInsurance[msg.sender], "No active insurance");
        // 在声明之间强制执行1天冷却，避免垃圾邮件
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");
        
        // 从天气预言机中获取最新降雨数据（利用解构忽略不需要的值）
        (uint80 roundId, int256 rainfall, , uint256 updatedAt, uint80 answeredInRound) = weatherOracle.latestRoundData();

        // 确保预言机数据最新有效
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        // 将降雨量转换为无符号格式
        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);

        // 索赔和支付
        // 降雨量低于干旱阈值，索赔流程继续进行
        if(currentRainfall < RAINFALL_THRESHOLD){
            // 记录时间防止背靠背索赔
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);

            // 实时汇率将50美元支出转换为ETH
            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;
            
            // 将 ETH 转移给农民
            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");
            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }
    
    // 提供以美元计价的最新 ETH 价格
    function getEthPrice() public view returns(uint256) {
        ( , int256 price, , ,) = ethUsdPriceFeed.latestRoundData();
        
        // 返回带有8位额外的数字（要除以1,0000,0000）
        return uint256(price);
    }

    // 任何人都能查看当前降雨量
    function getCurrentRainfall() public view returns(uint256){
        ( , int256 rainfall, , ,) = weatherOracle.latestRoundData();
        return uint256(rainfall);
    }

    // 合约所有者提取所有收集的 ETH
    function withdraw() external onlyOwner{
        payable (owner()).transfer(address(this).balance);
    }

    // 允许合约无需调用函数接收 ETH
    receive() external payable { }

    // 允许任何人查看合约当前持有多少 ETH
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}