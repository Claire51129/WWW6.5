// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CropInsurance
 * @dev 农作物干旱保险合约。
 * 原理：农民支付保费购买保单，如果预言机返回的降雨量低于阈值，合约自动允许理赔。
 */
contract CropInsurance {
    // 引用的天气预言机接口
    AggregatorV3Interface public weatherOracle;
    
    /// @dev 保单结构体，记录每一笔保险的详细信息
    struct Policy {
        address farmer;         // 投保农民地址
        uint256 premium;        // 已支付的保费
        uint256 coverage;       // 约定的理赔保额
        uint256 startTime;      // 保单生效时间
        uint256 endTime;        // 保单到期时间
        bool active;            // 保单当前是否有效
        bool claimed;           // 是否已经完成理赔
    }
    
    // 存储所有保单：保单ID => 保单详情
    mapping(uint256 => Policy) public policies;
    uint256 public nextPolicyId = 1; // 递增的保单ID
    
    // 核心业务参数：降雨量低于 20mm 触发理赔条件
    uint256 public constant DROUGHT_THRESHOLD = 20; 
    
    // 事件日志：用于前端监听保单创建和赔付情况
    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 coverage);
    event ClaimPaid(uint256 indexed policyId, address indexed farmer, uint256 amount);
    
    /**
     * @param _weatherOracle 部署时传入预言机合约地址
     */
    constructor(address _weatherOracle) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
    }
    
    /**
     * @notice 农民通过支付以太坊购买保险
     * @param _coverage 如果发生干旱，农民希望获得的赔付金额
     * @param _duration 保险持续时长（秒）
     */
    function buyInsurance(uint256 _coverage, uint256 _duration) external payable {
        require(msg.value > 0, "Premium required"); // 必须支付保费
        require(_coverage > 0, "Coverage must be positive");
        
        // 创建新保单并存入 mapping
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
     * @notice 申请理赔
     * @dev 核心逻辑：从预言机获取数据并进行数学判定
     * @param _policyId 想要申请理赔的保单编号
     */
    function claimInsurance(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        
        // --- 基础检查 ---
        require(policy.farmer == msg.sender, "Not policy owner");
        require(policy.active, "Policy not active");
        require(!policy.claimed, "Already claimed");
        require(block.timestamp <= policy.endTime, "Policy expired");
        
        // --- 获取外部客观数据 ---
        // 调用预言机的 latestRoundData，我们只需要 rainfall 和 updatedAt
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        
        // 确保预言机的数据是在保单生效后更新的，防止使用旧数据理赔
        require(updatedAt > policy.startTime, "No recent weather data");
        require(rainfall >= 0, "Invalid rainfall data");
        
        // --- 逻辑判定：是否干旱 ---
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            // 先修改状态，防止重入攻击（Reentrancy）
            policy.claimed = true;
            policy.active = false;
            
            // 执行赔付：合约将保额对应的以太坊转给农民
            // 注意：合约账户里必须有足够的余额（来自保费积累或其他资金池）
            payable(msg.sender).transfer(policy.coverage);
            
            emit ClaimPaid(_policyId, msg.sender, policy.coverage);
        } else {
            // 如果降雨充足，不予理赔并报错
            revert("Claim conditions not met");
        }
    }
    
    /**
     * @notice 视图函数：查看当前天气（方便前端展示）
     */
    function getCurrentWeather() external view returns (int256 rainfall, uint256 timestamp) {
        (, int256 answer, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        return (answer, updatedAt);
    }
    
    /**
     * @notice 预检查函数：在调用理赔前，先看看自己是否符合资格
     * @return eligible 是否符合理赔条件
     * @return reason 不符合的原因
     */
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