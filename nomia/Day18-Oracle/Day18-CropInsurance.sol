// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    AggregatorV3Interface private weatherOracle;

    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;
    // constant 常量部署后不能改
    // 雨量低于500就佩服 保费10美元赔付50美元

    //记录买过保险的地址
    mapping(address => bool) public hasInsurance;
    

    mapping(address => uint256) public lastClaimTimestamp;
    // 记录每个人上次 claim 的时间


    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);


    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        // 接入已经存在的oracle地址
    }

    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice();//ETH当前价格

        //美元eth换算
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured"); //查是否买了保险了已经

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");
        //lastClaimTimestamp+1 days 至少隔24小时

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();
        

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");
        //检查oracle数据是不是有效/旧数据

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);


        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);
        

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;
    

            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            //转账低级调用 "" 不给对方传任何函数调用数据只转钱

            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
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
        //owner把合约里的钱全部提走
    }

    receive() external payable {}
    //receive函数 允许别人直接往这个合约地址打ETH
    function getBalance() public view returns (uint256) {
        return address(this).balance;
        //查看合约里现在还有多少钱
    }
}