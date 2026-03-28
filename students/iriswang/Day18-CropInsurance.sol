// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 手动定义 Chainlink 接口（避免导入）
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract CropInsurance {
    AggregatorV3Interface public weatherOracle;
    
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
    
    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 coverage);
    event ClaimPaid(uint256 indexed policyId, address indexed farmer, uint256 amount);
    
    constructor(address _weatherOracle) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
    }
    
    function buyInsurance(uint256 _coverage, uint256 _duration) external payable {
        require(msg.value > 0, "Premium required");
        require(_coverage > 0, "Coverage must be positive");
        
        policies[nextPolicyId] = Policy({
            farmer: msg.sender,
            premium: msg.value,
            coverage: _coverage,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            active: true,
            claimed: false
        });
        
        emit PolicyCreated(nextPolicyId, msg.sender, _coverage);
        nextPolicyId++;
    }
    
    function claimInsurance(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        
        require(policy.farmer == msg.sender, "Not policy owner");
        require(policy.active, "Policy not active");
        require(!policy.claimed, "Already claimed");
        require(block.timestamp <= policy.endTime, "Policy expired");
        
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        
        require(updatedAt > policy.startTime, "No recent weather data");
        require(rainfall >= 0, "Invalid rainfall data");
        
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            policy.claimed = true;
            policy.active = false;
            payable(msg.sender).transfer(policy.coverage);
            emit ClaimPaid(_policyId, msg.sender, policy.coverage);
        } else {
            revert("Claim conditions not met");
        }
    }
    
    function getCurrentWeather() external view returns (int256 rainfall, uint256 timestamp) {
        (, int256 answer, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        return (answer, updatedAt);
    }
    
    function checkClaimEligibility(uint256 _policyId) external view returns (bool eligible, string memory reason) {
        Policy storage policy = policies[_policyId];
        
        if (!policy.active) return (false, "Policy not active");
        if (policy.claimed) return (false, "Already claimed");
        if (block.timestamp > policy.endTime) return (false, "Policy expired");
        
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        
        if (updatedAt <= policy.startTime) return (false, "No recent weather data");
        if (rainfall < 0) return (false, "Invalid rainfall data");
        
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            return (true, "Drought conditions met");
        } else {
            return (false, "Sufficient rainfall");
        }
    }
}
