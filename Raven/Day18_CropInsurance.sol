// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import "https://raw.githubusercontent.com/smartcontractkit/chainlink/refs/tags/contracts-v1.3.0/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable {
	AggregatorV3Interface private weatherOracle;
	AggregatorV3Interface private ethUsdPriceFeed;
	uint256 public constant RAINFALL_TRESHOLD = 900;
	uint256 public constant INSURANCE_PREMIUM_USD = 10;
	uint256 public constant INSURANCE_PAYOUT_USD = 10;
	mapping(address => bool) public hasInsurance;
	mapping(address => uint256) public lastClaimTimestamp;
	event InsurancePurchase(address indexed farmer, uint256 amount);
	event ClaimSubmit(address indexed farmer);
	event ClaimPaid(address indexed farmer, uint256 amount);
	event RainfallCheck(address indexed farmer, uint256 rainfall);
	constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender) {
		weatherOracle = AggregatorV3Interface(_weatherOracle);
		ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
	}
	function purchaseInsurance() external payable {
		uint256 ethPrice = getEthPrice();
		// ethPrice is 1e8 times USD
		uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e26) / ethPrice;
		require(msg.value >= premiumInEth, "Insufficient payment");
		require(!hasInsurance[msg.sender], "Already insured");
		hasInsurance[msg.sender] = true;
		emit InsurancePurchase(msg.sender, msg.value);
	}
	function checkRainfallAndClaim() external {
		require(hasInsurance[msg.sender], "No insurance");
		// Add interval between claims
		require(block.timestamp >= lastClaimTimestamp[msg.sender] + 1 days, "Must wait 1 day between claims");
		(
			uint80 roundId,
			int256 rainfall,
			,
			uint256 updateAt,
			uint80 answeredInRound
		) = weatherOracle.latestRoundData();
		require(updateAt > 0, "Round not complete");
		require(answeredInRound >= roundId, "Stale data");
		uint256 currentRainfall = uint256(rainfall);
		emit RainfallCheck(msg.sender, currentRainfall);
		// Claim and get insurance payment
		if (currentRainfall < RAINFALL_TRESHOLD) {
			lastClaimTimestamp[msg.sender] = block.timestamp;
			emit ClaimSubmit(msg.sender);
			uint256 ethPrice = getEthPrice();
			uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e26) / ethPrice;
			(bool success, ) = msg.sender.call{value:payoutInEth}("");
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
	}
	receive() external payable {}
	function getBalance() public view returns (uint256) {
		return address(this).balance;
	}
}