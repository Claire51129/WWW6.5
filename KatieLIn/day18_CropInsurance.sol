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

    uint256 public constant MAX_CLAIMS_PER_POLICY = 3;

    mapping(address => bool) public hasInsurance;
    mapping(address => uint256) public lastClaimTimestamp;
    mapping(address => uint256) public claimCount; 

    event InsurancePurchased(address indexed farmer, uint256 amount);
    event ClaimSubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 rainfall);
    event Refunded(address indexed farmer, uint256 amount); 

    constructor(address _weatherOracle, address _ethUsdPriceFeed)
        payable
        Ownable(msg.sender)
    {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable {
        require(!hasInsurance[msg.sender], "Already insured");

        uint256 ethPrice = getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;
        require(msg.value >= premiumInEth, "Insufficient premium amount");

        hasInsurance[msg.sender] = true;
        claimCount[msg.sender] = 0;

        uint256 excess = msg.value - premiumInEth;
        if (excess > 0) {
            (bool refunded, ) = msg.sender.call{value: excess}("");
            require(refunded, "Refund failed");
            emit Refunded(msg.sender, excess);
        }

        emit InsurancePurchased(msg.sender, premiumInEth);
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender], "No active insurance");
        require(
            block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days,
            "Must wait 24h between claims"
        );
        require(claimCount[msg.sender] < MAX_CLAIMS_PER_POLICY, "Claim limit reached");

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();

        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");
        require(rainfall >= 0, "Invalid rainfall data");

        uint256 currentRainfall = uint256(rainfall);
        emit RainfallChecked(msg.sender, currentRainfall);

        if (currentRainfall < RAINFALL_THRESHOLD) {
            lastClaimTimestamp[msg.sender] = block.timestamp;
            claimCount[msg.sender]++; 

            if (claimCount[msg.sender] >= MAX_CLAIMS_PER_POLICY) {
                hasInsurance[msg.sender] = false;
            }

            emit ClaimSubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;
            require(address(this).balance >= payoutInEth, "Insufficient contract balance");

            (bool success, ) = msg.sender.call{value: payoutInEth}("");
            require(success, "Transfer failed");
            emit ClaimPaid(msg.sender, payoutInEth);
        }
    }

    function getEthPrice() public view returns (uint256) {
        (
            uint80 roundId,
            int256 price,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = ethUsdPriceFeed.latestRoundData();

        require(price > 0, "Invalid ETH price");
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale price data");

        return uint256(price);
    }

    function getCurrentRainfall() public view returns (uint256) {
        (, int256 rainfall, , , ) = weatherOracle.latestRoundData();
        require(rainfall >= 0, "Invalid rainfall data");
        return uint256(rainfall);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}