// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Day 18 - Crop Insurance Contract (Clean Version)
 * 
 * Uses oracle to fetch rainfall data for automatic claim processing
 */
interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract CropInsurance {
    
    AggregatorV3Interface public weatherOracle;
    address public owner;
    
    struct Policy {
        address farmer;
        uint256 premium;
        uint256 coverage;
        uint256 startTime;
        uint256 endTime;
        bool active;
        bool claimed;
    }
    
    uint256 public constant DROUGHT_THRESHOLD = 20;
    uint256 public constant DATA_FRESHNESS = 1 hours;
    
    mapping(uint256 => Policy) public policies;
    uint256 public nextPolicyId;
    
    uint256 public totalPremiums;
    uint256 public totalClaimsPaid;
    
    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 premium, uint256 coverage);
    event ClaimPaid(uint256 indexed policyId, address indexed farmer, uint256 amount, int256 rainfall);
    event ClaimRejected(uint256 indexed policyId, address indexed farmer, string reason);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor(address _weatherOracle) {
        require(_weatherOracle != address(0), "Invalid oracle address");
        weatherOracle = AggregatorV3Interface(_weatherOracle);
        owner = msg.sender;
        nextPolicyId = 1;
    }
    
    function buyInsurance(uint256 _coverage, uint256 _duration) external payable {
        require(msg.value > 0, "Premium required");
        require(_coverage > 0, "Coverage must be positive");
        require(_coverage > msg.value, "Coverage must be greater than premium");
        require(_duration > 0, "Duration must be positive");
        require(address(this).balance >= _coverage, "Insufficient funds in contract");
        
        uint256 policyId = nextPolicyId++;
        
        policies[policyId] = Policy({
            farmer: msg.sender,
            premium: msg.value,
            coverage: _coverage,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            active: true,
            claimed: false
        });
        
        totalPremiums += msg.value;
        
        emit PolicyCreated(policyId, msg.sender, msg.value, _coverage);
    }
    
    function claimInsurance(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        
        require(policy.farmer == msg.sender, "Not policy owner");
        require(policy.active, "Policy not active");
        require(!policy.claimed, "Already claimed");
        require(block.timestamp >= policy.startTime, "Policy not started");
        require(block.timestamp <= policy.endTime, "Policy expired");
        
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        
        require(updatedAt >= policy.startTime - DATA_FRESHNESS, "No recent weather data");
        require(rainfall >= 0, "Invalid rainfall data");
        
        uint256 rainfallUint = uint256(rainfall);
        
        if (rainfallUint < DROUGHT_THRESHOLD) {
            policy.claimed = true;
            policy.active = false;
            totalClaimsPaid += policy.coverage;
            
            (bool success, ) = payable(policy.farmer).call{value: policy.coverage}("");
            require(success, "Transfer failed");
            
            emit ClaimPaid(_policyId, msg.sender, policy.coverage, rainfall);
        } else {
            emit ClaimRejected(_policyId, msg.sender, "Rainfall above threshold");
            revert("No drought detected");
        }
    }
    
    function checkClaimEligibility(uint256 _policyId) 
        external 
        view 
        returns (bool eligible, string memory message, uint256 rainfall) 
    {
        Policy storage policy = policies[_policyId];
        
        if (policy.farmer == address(0)) {
            return (false, "Policy does not exist", 0);
        }
        if (!policy.active) {
            return (false, "Policy not active", 0);
        }
        if (policy.claimed) {
            return (false, "Already claimed", 0);
        }
        if (block.timestamp < policy.startTime) {
            return (false, "Policy not started", 0);
        }
        if (block.timestamp > policy.endTime) {
            return (false, "Policy expired", 0);
        }
        
        (, int256 rainfallData, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        
        if (updatedAt < policy.startTime - DATA_FRESHNESS) {
            return (false, "Weather data too old", 0);
        }
        if (rainfallData < 0) {
            return (false, "Invalid rainfall data", 0);
        }
        
        uint256 rainfallUint = uint256(rainfallData);
        
        if (rainfallUint < DROUGHT_THRESHOLD) {
            return (true, "Eligible for claim - Drought detected", rainfallUint);
        } else {
            return (false, "Not eligible - No drought", rainfallUint);
        }
    }
    
    function getCurrentWeather() external view returns (
        int256 rainfall,
        uint256 updatedAt,
        bool isDrought
    ) {
        (, rainfall, , updatedAt, ) = weatherOracle.latestRoundData();
        isDrought = rainfall >= 0 && uint256(rainfall) < DROUGHT_THRESHOLD;
    }
    
    function getPolicyDetails(uint256 _policyId) external view returns (
        address farmer,
        uint256 premium,
        uint256 coverage,
        uint256 startTime,
        uint256 endTime,
        bool active,
        bool claimed,
        uint256 timeRemaining
    ) {
        Policy storage p = policies[_policyId];
        farmer = p.farmer;
        premium = p.premium;
        coverage = p.coverage;
        startTime = p.startTime;
        endTime = p.endTime;
        active = p.active;
        claimed = p.claimed;
        
        if (block.timestamp < p.endTime) {
            timeRemaining = p.endTime - block.timestamp;
        } else {
            timeRemaining = 0;
        }
    }
    
    function updateOracle(address _newOracle) external onlyOwner {
        require(_newOracle != address(0), "Invalid address");
        weatherOracle = AggregatorV3Interface(_newOracle);
    }
    
    function withdrawExcess() external onlyOwner {
        uint256 excess = address(this).balance - (totalClaimsPaid - totalPremiums);
        require(excess > 0, "No excess funds");
        (bool success, ) = payable(owner).call{value: excess}("");
        require(success, "Transfer failed");
    }
    
    function fund() external payable onlyOwner {}
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    receive() external payable {}
}