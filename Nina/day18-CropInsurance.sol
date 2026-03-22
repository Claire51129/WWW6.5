// 农作物保险. 该合约模拟了基于区块链的农作物保险计划。农民可以支付少量溢价，如果降雨量低于阈值，他们会自动获得报酬——没有中间商，没有等待。


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
    AggregatorV3Interface private weatherOracle; // 负责查天气（获取降雨量）
    AggregatorV3Interface private ethUsdPriceFeed; // 负责查币价（获取 ETH/USD 价格）
    // 这两个变量是符合 Chainlink V3 标准接口 的合约，应该拥有 latestRoundData()、getRoundData() 等特定的功能。
    // 为什么需要查币价？ 因为我们的保费和赔付是以美元定价的，但以太坊合约里支付的是 ETH。为了算出 10 美元等于多少 ETH，我们必须实时获取币价。

    uint256 public constant RAINFALL_THRESHOLD = 500; // 赔付阈值。降雨量低于 500mm 就判定为干旱，触发赔付
    uint256 public constant INSURANCE_PREMIUM_USD = 10; // 美元保费，固定为 10 美元
    uint256 public constant INSURANCE_PAYOUT_USD = 50; // 赔付额，固定为 50 美元（5倍杠杆）
    // 定义常数，不可篡改

    mapping(address => bool) public hasInsurance; // 某农民是否已投保
    mapping(address => uint256) public lastClaimTimestamp; // 某农民上次领取理赔的时间戳

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle); // 这是我们的降雨预言机的地址（就像我们之前构建的模拟一样）
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed); // 这是 Chainlink 价格馈送的地址，可为我们提供 ETH → USD 的转换（https://docs.chain.link/data-feeds/price-feeds/addresses）
    }

    function purchaseInsurance() external payable {
        uint256 ethPrice = getEthPrice(); // 获取当前ETH的美元价格
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice; // 计算ETH保费。如果 ETH 是 $2000，计算过程大致是 $(10 * 10^{18}) / 2000 = 0.005 * 10^{18}$ Wei。

        require(msg.value >= premiumInEth, "Insufficient premium amount");
        require(!hasInsurance[msg.sender], "Already insured");

        hasInsurance[msg.sender] = true;
        emit InsurancePurchased(msg.sender, msg.value);
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 24h between claims");

        (
            uint80 roundId,
            int256 rainfall,
            , 
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();
        // 从我们的天气预言机中提取最新的降雨数据

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");
        // 基本检查以确保预言机数据是最新且有效的

        uint256 currentRainfall = uint256(rainfall); // 对rainfall完成从int256到uint256的类型转换，以便下方与uint256 RAINFALL_THRESHOLD做比较
        emit RainfallChecked(msg.sender, currentRainfall); 

        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp;
            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;

            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");

            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    // 获取最新价格（Chainlink 预言机在返回 ETH/USD 价格时，统一规定使用 8 位精度）
    function getEthPrice() public view returns (uint256) {
        (
            ,
            int256 price,
            ,
            ,
        ) = ethUsdPriceFeed.latestRoundData(); // （构造函数中对ethUsdPriceFeed赋值为官方价格馈送合约地址，这里调用的是该合约中的同名函数。）

        return uint256(price);
    }

    // 获取最新降雨量
    function getCurrentRainfall() public view returns (uint256) {
        (
            ,
            int256 rainfall,
            ,
            ,
        ) = weatherOracle.latestRoundData();
        /** 等号右侧：函数调用。打包了一个元组，包含五个不同类型的数据。（构造函数中对weatherOracle赋值为我们的模拟器合约地址，这里调用的是模拟器合约中的同名函数。）
            等号：解构赋值。将右侧数据一一对应地赋值给左侧变量。
            等号左侧：变量声明。其中逗号占位表示忽略不重要的值。
         */

        return uint256(rainfall);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    // 让合约所有者提取所有收集的 ETH（例如，未使用的premium）

    receive() external payable {}
    // 允许合约无需调用函数接收 ETH

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    // 允许任何人查看合约当前持有多少 ETH
}

