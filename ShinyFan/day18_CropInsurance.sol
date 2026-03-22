// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    AggregatorV3Interface private weatherOracle;//查看降雨量
    AggregatorV3Interface private ethUsdPriceFeed;//查看ETH价格

    uint256 public constant RAINFALL_THRESHOLD = 500;//constant = 固定不变的常量  下雨阈值 500
    uint256 public constant INSURANCE_PREMIUM_USD = 10;//保险费用为10元
    uint256 public constant INSURANCE_PAYOUT_USD = 50;//赔偿50元

    mapping(address => bool) public hasInsurance;//谁买了保险
    mapping(address => uint256) public lastClaimTimestamp;//某人最后索赔时间

    event InsurancePurchased(address indexed farmer, uint256 amount);//谁买了，花了多少钱
    event ClaimSubmitted(address indexed farmer);//谁申请了赔款
    event ClaimPaid(address indexed farmer, uint256 amount);//谁收到了多少赔款
    event RainfallChecked(address indexed farmer, uint256 rainfall);//谁检查了降雨量，降雨量为xxx

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);//前端可以添加之前写好的天气预报地址
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);//查询ETH价格
    }

    //购买保险
    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();//使用 Chainlink 获取 ETH 的当前美元价格
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;//将美元转换成ETH

        require(msg.value >= premiumInEth, "Insufficient premium amount");//保证用户账户有钱
        require(!hasInsurance[msg.sender], "Already insured");//确保不重复购买保险

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);//发送购买保险时间
    }

    //确认降雨量和自动赔款
    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");//需要间隔24小时

        (
            uint80 roundId,
            int256 rainfall,
            ,//跳过原本设定的第三个值，startedAt，这次不需要这个值
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();//从天气预言机中提取最新的降雨数据，一一对应放到左侧括号中的变量里

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);//获取当前降雨量
        emit RainfallChecked(msg.sender, currentRainfall);//播报当前降雨量

        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp;//更新索赔时间为现在区块链时间
            emit ClaimSubmitted(msg.sender);//播报索赔信息

            uint256 ethPrice = getEthPrice();//获取当前美元和ETH汇率
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;//计算当前美元是多少ETH

            (bool success, ) = msg.sender.call{value: payoutInEth}("");//(是否成功, ) = 接收地址.call{value: 转多少钱}("");  只转钱不发消息就写("")
            require(success, "Transfer failed");//检查转钱是否成功

            emit ClaimPaid(msg.sender, payoutInEth);//播报谁获得了多少索赔
        }
    }

    //提供以美元计价的最新 ETH 价格。
    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    //查看当前降雨量
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();

        return uint256(rainfall);
    }

    //管理员提取合约里的余额
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);//owner()，括号里填写管理员的地址
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
