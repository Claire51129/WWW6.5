//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract CropInsurance is Ownable {
    AggregatorV3Interface public weatherOracle;
    AggregatorV3Interface public ethUsdPriceFeed;
    struct Policy {
        address farmer;
        uint256 premium;
        uint256 coverage;
        uint256 startTime;
        uint256 endTime;
        bool active;
        bool claimed;
    }

    mapping(uint256 => Policy) public policies;
    uint256 public nextPolicyId = 1;
    uint256 public constant DROUGHT_THRESHOLD = 20;
    uint256 public constant INSURANCE_PREMIUN_USD = 10;
    uint256 public constant INSURANCE_PAYOUT_USD = 50;
    event PolicyCreated(uint256 indexed policyId, address farmer, uint256 coverage);
    event ClaimPaid(uint256 indexed policyId, address farmer, uint256 amount);

    constructor(address _weatherOracle, address _ethUsdPriceFeed) Ownable(msg.sender) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function getEthPrice() public view returns(uint256) {
        (,int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        require(price > 0,"Invalid price");
        return uint256(price);
    }

    function buyInsurance(uint256 _duration) external payable {
        uint256 ethPrice = getEthPrice();
        uint256 premiumInEth = (INSURANCE_PREMIUN_USD * 1e18)/ethPrice;
        require(msg.value >= premiumInEth,"Premium too low");
        uint256 coverage = (INSURANCE_PAYOUT_USD * 1e18)/ethPrice;
        policies[nextPolicyId] = Policy({
            farmer: msg.sender,
            premium: msg.value,
            coverage: coverage,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            active: true,
            claimed: false
        });
        emit PolicyCreated(nextPolicyId, msg.sender, coverage);
        unchecked{
            nextPolicyId++;
        }
    }

    function claimInsurance(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        require(policy.farmer == msg.sender,"Not Owner");
        require(policy.active, "Not Active");
        require(!policy.claimed, "Already Claimed");
        uint256 currentTime = block.timestamp;
        require(currentTime <= policy.endTime,"Expired");
        (
            uint80 roundId,
            int256 rainfall,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = weatherOracle.latestRoundData();
        require(updatedAt > 0,"Round incomplete");
        require(answeredInRound >= roundId,"Stale data");
        require(updatedAt > policy.startTime,"No recent data");
        require(rainfall >= 0,"Invalid data");
        if(uint256(rainfall) < DROUGHT_THRESHOLD) {
            policy.claimed = true;
            policy.active = false;
            (bool success,) = msg.sender.call{value: policy.coverage}("");
            require(success,"Transfer failed");
            emit ClaimPaid(_policyId, msg.sender, policy.coverage);
        } else {
            revert("Condition not met");
        }
    }

    function getCurrentWeather() external view returns(int256 rainfall,uint256 timestamp) {
        (,int256 answer,,uint256 updatedAt,) = weatherOracle.latestRoundData();
        return(answer, updatedAt);
    }

    function checkClaimEligibility(uint256 _policyId) external view returns(bool eligible, string memory) {
        Policy storage policy = policies[_policyId];
        if(!policy.active) return(false,"Not active");
        if(policy.claimed) return(false,"Claimed");
        if(block.timestamp > policy.endTime) return(false,"Expired");
        (,int256 rainfall,,uint256 updatedAt,) = weatherOracle.latestRoundData();
        if(updatedAt <= policy.startTime) return(false,"No data");
        if(rainfall < 0) return(false,"Invalid");
        if(uint256(rainfall) < DROUGHT_THRESHOLD) {
            return(true,"Drought");
        } else {
            return(false,"Rain OK");
        }
    }

    function withdraw() external onlyOwner{
        payable (owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}
