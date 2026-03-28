// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Day 18 - Chainlink Price Feed Example
 * 
 * Uses Chainlink Data Feeds to fetch ETH/USD real-time price
 * 
 * Sepolia Testnet ETH/USD Price Feed Address:
 * 0x694AA1769357215DE4FAC081bf1f309aDC325306
 * 
 * More price pairs: https://docs.chain.link/data-feeds/price-feeds/addresses
 */
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract PriceConsumer {
    
    AggregatorV3Interface internal priceFeed;
    
    /**
     * Constructor
     * @param _priceFeed ETH/USD price feed address
     */
    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    
    /**
     * Get latest ETH/USD price
     * @return price (with 8 decimal places)
     * Example: 2000.50 USD returns 200050000000
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            int256 price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        
        return price;
    }
    
    /**
     * Get full price data
     */
    function getPriceData() public view returns (
        uint80 roundId,
        int256 price,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return priceFeed.latestRoundData();
    }
    
    /**
     * Get price decimals
     * ETH/USD typically has 8 decimals
     */
    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
    
    /**
     * Get human-readable price format (with decimal point)
     * @return price string, e.g. "2000.50"
     */
    function getReadablePrice() public view returns (string memory) {
        int256 price = getLatestPrice();
        uint8 decimals = getDecimals();
        
        uint256 priceUint = uint256(price);
        
        uint256 divisor = 10 ** decimals;
        uint256 integerPart = priceUint / divisor;
        uint256 decimalPart = priceUint % divisor;
        
        return string(abi.encodePacked(
            uint2str(integerPart),
            ".",
            uint2str(decimalPart)
        ));
    }
    
    /**
     * Calculate ETH amount equivalent to USD
     * @param usdAmount USD amount (with 8 decimals)
     * @return wei equivalent ETH amount (wei)
     */
    function usdToEth(uint256 usdAmount) public view returns (uint256) {
        int256 price = getLatestPrice();
        require(price > 0, "Invalid price");
        
        return (usdAmount * 1e18) / uint256(price);
    }
    
    /**
     * Calculate USD amount equivalent to ETH
     * @param ethAmount ETH amount (wei)
     * @return USD amount (with 8 decimals)
     */
    function ethToUsd(uint256 ethAmount) public view returns (uint256) {
        int256 price = getLatestPrice();
        require(price > 0, "Invalid price");
        
        return (ethAmount * uint256(price)) / 1e18;
    }
    
    /**
     * Helper: uint to string conversion
     */
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}