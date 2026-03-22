//SPDX-License-Identifier:MIT
pragma  solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CropInsurance is Ownable{
    AggregatorV3Interface private weatherOracle;
    AggregatorV3Interface private ethUsdPriceFeed;

    uint256 public constant RAINFALL_THRESHOLD = 500;
    uint256 public constant INSURANCE_PREMIUM_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;

    mapping(address => bool) public hasInsurance;
    mapping(address => uint256) public LastClaimTimstamp;

    event insurancePurchased(address indexed farmer, uint256 amount);
    event Claimsubmitted(address indexed farmer);
    event ClaimPaid(address indexed farmer, uint256 amount);
    event RainfallChecked(address indexed farmer, uint256 amount);

    constructor(address _weatherOracle, address _ethUsdPriceFeed) payable Ownable(msg.sender){
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function purchaseInsurance() external payable{
        uint256 ethPrice = getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUM_USD * 1e18)/ethPrice;

        require(msg.value > premiumInEth, "insufficient premium amount");
        require(!hasInsurance[msg.sender], "Alredy insurance");

        hasInsurance[msg.sender] = true;
        emit insurancePurchased(msg.sender, msg.value);
    }

    function checkRainfallAndClaim() external {
        require(hasInsurance[msg.sender],"No active Insurance");
        require(block.timestamp > LastClaimTimstamp[msg.sender] + 1 days, "Must wait 24h between claims");

        (uint80 roundID, int256 rainfall, , uint256 updataAt, uint80 answeredInRound) = weatherOracle.latestRoundData();

        require(updataAt>0,"Round not complete");
        require(answeredInRound > roundID, "stale data");

        uint256 currentRainFall =uint256(rainfall);
        emit RainfallChecked(msg.sender,  currentRainFall);

        if(currentRainFall < RAINFALL_THRESHOLD){
            LastClaimTimstamp[msg.sender] = block.timestamp;
            emit Claimsubmitted(msg.sender);

            uint256 ethPrice = getEthPrice();
            uint256 payoutInEth = (INSURANCE_PAYOUT_USD * 1e18)/ethPrice;

            (bool success, ) = msg.sender.call{value:payoutInEth}("");
            require(success, "transfer failed");

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

    function getCurrentRainfall() external view returns(uint256){
        (, int256 rainfall, , , ) = weatherOracle.latestRoundData();
        return uint256(rainfall);
    }

    function withdraw () external onlyOwner{
        payable (owner()).transfer(address(this).balance);
    }

    receive() external payable{}

    function getBlance() external view returns(uint256){
        return address(this).balance;
    }


}

