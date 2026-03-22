
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    //私有的、符合 Chainlink V3 预言机接口规范的变量，用于指向提供天气数据的预言机合约
    AggregatorV3Interface private weatherOracle;
    //通过变量调用 AggregatorV3Interface 接口的方法，从 Chainlink 预言机获取实时、可信的 ETH 对 USD 的价格
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500; //constant常量修饰符：变量值部署后永不可修改
    uint256 public constant INSURANCE_PREMIUM_USD = 10;//保险费美元
    uint256 public constant INSURANCE_PAYOUT_USD = 50;//保险支付金美元

    mapping(address => bool) public hasInsurance;  //已保险
    mapping(address => uint256) public lastClaimTimestamp; //最后索赔时间戳

    event InsurancePurchased(address indexed farmer, uint256 amount);//已购保险事件
    event ClaimSubmitted(address indexed farmer);//索赔提交事件
    event ClaimPaid(address indexed farmer, uint256 amount);//已支付索赔事件
    event RainfallChecked(address indexed farmer, uint256 rainfall);//已检查降雨量事件

    constructor(
        address _weatherOracle, //降雨预言机的地址
        address _ethUsdPriceFeed //提供 ETH → USD 的转换的地址
    ) payable Ownable(msg.sender) {
        //在_weatherOracle这个地址上，有一个合约实现了AggregatorV3Interface接口，我要通过weatherOracle这个实例来调用它的函数
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable {  //从用户处接收ETH
        uint256 ethPrice = getEthPrice();  //获取 ETH 的当前美元价格
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;//转换为ETH

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");

        hasInsurance[msg.sender] = true; //标记已投保  
        emit InsurancePurchased(msg.sender, msg.value); //触发已购买保险事件
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        //强制执行1 天的冷却，以避免垃圾邮件
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();//从天气预言机中提取最新的降雨数据

        //确保预言机数据是最新且有效的
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall); //触发降雨量评估事件

        if (currentRainfall < RAINFALL_THRESHOLD) {  //降雨量低于阈值触发索赔提交事件
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;

            (bool success, ) = msg.sender.call{value: payoutInEth}(""); //将 ETH 转移给农民
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth); //事件索赔已支付
        }
    }

    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData();

        return uint256(price);
    }

    //查看降雨量
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
        //合约所有者提取所有收集的 ETH
        payable(owner()).transfer(address(this).balance);
    }

    //允许合约无需调用函数接收 ETH
    receive() external payable {}

    //任何人查看合约当前持有多少 ETH
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

