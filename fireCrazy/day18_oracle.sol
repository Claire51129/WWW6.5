// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 1. 直接定义接口 (Interface)
 */
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PriceConsumerV3 {
    // 声明预言机接口变量
    AggregatorV3Interface internal priceFeed;

    /**
     * 网络: Sepolia 测试网
     * 聚合器: ETH/USD
     * 地址: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        // 初始化预言机地址
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    /**
     * 获取最新价格并对齐到 18 位精度
     */
    function getLatestPrice() public view returns (uint256) {
        (
            /* uint80 roundID */,
            int256 price, // 得到 8 位精度的价格
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();

        // 将 8 位精度补齐到 18 位 (乘以 10^10)
        return uint256(price) * 1e10;
    }

    /**
     * 实战转换：输入 ETH 数量，返回对应的 USD 价值（均为 18 位精度）
     * 公式：(Amount * Price) / 1e18
     */
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getLatestPrice();
        
        // 先乘后除，防止精度丢失
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        
        return ethAmountInUsd;
    }
}
