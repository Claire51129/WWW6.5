// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 导入文件 1，其中包含了 AggregatorV3Interface 接口定义
import "./day18_oracle.sol";

/**
 * @title day18_insurance
 * @dev 农作物干旱保险合约
 * 
 * 文件名: day18_insurance.sol
 * 合约名: day18_insurance
 */
contract day18_insurance {
    // 使用接口类型引用预言机
    AggregatorV3Interface public weatherOracle;

    struct Policy {
        address farmer;
        uint256 premium;        // 保费
        uint256 coverage;       // 保额
        uint256 startTime;
        uint256 endTime;
        bool active;
        bool claimed;
    }

    mapping(uint256 => Policy) public policies;
    uint256 public nextPolicyId = 1;
    
    // 干旱阈值：降雨量低于此值 (mm) 触发理赔
    uint256 public constant DROUGHT_THRESHOLD = 20;

    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 coverage);
    event ClaimPaid(uint256 indexed policyId, address indexed farmer, uint256 amount);
    event ClaimRejected(uint256 indexed policyId, string reason);

    /**
     * @param _weatherOracle 预言机合约地址 (部署 day18_oracle 后获得的地址)
     */
    constructor(address _weatherOracle) {
        require(_weatherOracle != address(0), "Invalid oracle address");
        weatherOracle = AggregatorV3Interface(_weatherOracle);
    }

    /**
     * @dev 购买保险
     * @param _coverage 保额 (理赔时获得的金额)
     * @param _duration 保险时长 (秒)
     */
    function buyInsurance(uint256 _coverage, uint256 _duration) external payable {
        require(msg.value > 0, "Premium required");
        require(_coverage > 0, "Coverage must be positive");
        require(_duration > 0, "Duration must be positive");

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

    /**
     * @dev 申请理赔
     * 条件：保单有效 + 未理赔 + 未过期 + 降雨量 < 阈值
     */
    function claimInsurance(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];

        // 基础验证
        require(policy.farmer == msg.sender, "Not policy owner");
        require(policy.active, "Policy not active");
        require(!policy.claimed, "Already claimed");
        require(block.timestamp <= policy.endTime, "Policy expired");

        // 获取天气数据
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();

        require(updatedAt >= policy.startTime, "No valid weather data during policy period");
        require(rainfall >= 0, "Invalid rainfall data");

        // 检查干旱条件
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            policy.claimed = true;
            policy.active = false;

            // 支付理赔金
            (bool success, ) = payable(msg.sender).call{value: policy.coverage}("");
            require(success, "Transfer failed");

            emit ClaimPaid(_policyId, msg.sender, policy.coverage);
        } else {
            emit ClaimRejected(_policyId, "Sufficient rainfall");
            revert("Claim conditions not met: Rainfall is sufficient");
        }
    }

    /**
     * @dev 查看当前天气数据
     */
    function getCurrentWeather() external view returns (int256 rainfall, uint256 timestamp) {
        (, int256 answer, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        return (answer, updatedAt);
    }

    /**
     * @dev 检查理赔资格 (View 函数，不消耗 Gas)
     */
    function checkClaimEligibility(uint256 _policyId) external view returns (bool eligible, string memory reason) {
        Policy storage policy = policies[_policyId];

        if (!policy.active) return (false, "Policy not active");
        if (policy.claimed) return (false, "Already claimed");
        if (block.timestamp > policy.endTime) return (false, "Policy expired");

        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();

        if (updatedAt < policy.startTime) return (false, "No recent weather data");
        if (rainfall < 0) return (false, "Invalid rainfall data");

        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            return (true, "Drought conditions met");
        } else {
            return (false, "Sufficient rainfall");
        }
    }
    
    /**
     * @dev 获取合约余额 (方便测试资金是否充足)
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev 紧急提现 (防止资金锁死，仅限所有者，实际生产环境需加权限控制)
     * 这里为了简化作业逻辑暂不添加 Owner 修饰符，仅作为测试用
     */
    function withdraw() external {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}