// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day18_AggregatorV3Interface.sol";

contract CropInsurance {

    address public owner;
    AggregatorV3Interface public weatherOracle;
    AggregatorV3Interface public ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;
    uint256 public constant INSURANCE_VALIDITY = 90 days;
    uint256 public constant CLAIM_COOLDOWN = 1 days;

    struct Policy {
        bool active;
        uint256 purchasedAt;
        uint256 lastClaimTime;
    }

    mapping(address => Policy) public policies;

    event InsurancePurchased(address indexed farmer, uint256 premiumPaid, uint256 expiresAt);
    event ClaimApproved(address indexed farmer, uint256 payoutAmount, uint256 rainfall);
    event ClaimDenied(address indexed farmer, uint256 rainfall);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable {
        owner = msg.sender;
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable {
        require(!_isActive(msg.sender), "Already have active insurance");

        uint256 ethPrice = _getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18) / ethPrice;
        require(msg.value >= premiumInEth, "Insufficient premium");

        policies[msg.sender] = Policy({
            active: true,
            purchasedAt: block.timestamp,
            lastClaimTime: 0
        });

        emit InsurancePurchased(msg.sender, msg.value, block.timestamp + INSURANCE_VALIDITY);
    }

    function checkRainfallAndClaim() external {
        require(_isActive(msg.sender), "No active insurance policy");
        require(
            block.timestamp >= policies[msg.sender].lastClaimTime + CLAIM_COOLDOWN,
            "Must wait 24 hours between claims"
        );

        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();

        require(updatedAt > 0, "Oracle round not complete");
        require(answeredInRound >= roundId, "Stale oracle data");

        uint256 currentRainfall = uint256(rainfall);
        policies[msg.sender].lastClaimTime = block.timestamp;

        if (currentRainfall < RAINFALL_THRESHOLD) {
            uint256 ethPrice = _getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18) / ethPrice;

            require(address(this).balance >= payoutInEth, "Insufficient contract balance");
            (bool sent, ) = msg.sender.call{value: payoutInEth}("");
            require(sent, "Payout transfer failed");

            emit ClaimApproved(msg.sender, payoutInEth, currentRainfall);
        } else {
            emit ClaimDenied(msg.sender, currentRainfall);
        }
    }

    function _isActive(address _farmer) internal view returns (bool) {
        Policy memory p = policies[_farmer];
        return p.active && block.timestamp <= p.purchasedAt + INSURANCE_VALIDITY;
    }

    function isInsured(address _farmer) external view returns (bool) {
        return _isActive(_farmer);
    }

    function getPolicyInfo(address _farmer) external view returns (
        bool active,
        uint256 purchasedAt,
        uint256 expiresAt,
        uint256 lastClaim
    ) {
        Policy memory p = policies[_farmer];
        return (
            _isActive(_farmer),
            p.purchasedAt,
            p.purchasedAt + INSURANCE_VALIDITY,
            p.lastClaimTime
        );
    }

    function getCurrentRainfall() external view returns (uint256) {
        (, int256 rainfall, , , ) = weatherOracle.latestRoundData();
        return uint256(rainfall);
    }

    function getEthPricePublic() external view returns (uint256) {
        return _getEthPrice();
    }

    function _getEthPrice() internal view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "Invalid ETH price");
        return uint256(price);
    }
    
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "Nothing to withdraw");
        payable(owner).transfer(bal);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
