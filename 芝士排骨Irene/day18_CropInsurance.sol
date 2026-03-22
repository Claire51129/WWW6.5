// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 农作物保险合约
// 核心逻辑：农民买保险 → 预言机监测降雨量 → 降雨量低于阈值（干旱）→ 自动理赔
contract CropInsurance {

    // 天气预言机接口 - 通过这个接口获取链下的降雨量数据
    // 可以指向 MockWeatherOracle（测试）或 Chainlink 真实预言机（生产）
    AggregatorV3Interface public weatherOracle;

    // 保险单结构体
    struct Policy {
        address farmer;     // 投保人地址
        uint256 premium;    // 保费（用户支付的 ETH）
        uint256 coverage;   // 保额（理赔时支付给用户的金额）
        uint256 startTime;  // 保单生效时间
        uint256 endTime;    // 保单到期时间
        bool active;        // 保单是否有效
        bool claimed;       // 是否已理赔（防止重复理赔）
    }

    // 保单 ID => 保单详情
    mapping(uint256 => Policy) public policies;

    // 下一个保单 ID（自增，从 1 开始）
    uint256 public nextPolicyId = 1;

    // 干旱阈值 - 降雨量低于 20 毫米视为干旱，触发理赔
    // constant：编译时确定，不占存储槽，读取零 gas
    uint256 public constant DROUGHT_THRESHOLD = 20;

    // 事件
    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 coverage); // 保单创建
    event ClaimPaid(uint256 indexed policyId, address indexed farmer, uint256 amount);        // 理赔支付

    // 构造函数 - 传入天气预言机的合约地址
    // 测试时传 MockWeatherOracle 的地址，上线时传 Chainlink 真实地址
    // 两者都实现了 AggregatorV3Interface，所以业务代码不用改
    constructor(address _weatherOracle) {
        weatherOracle = AggregatorV3Interface(_weatherOracle);
    }

    // 购买保险 - 农民付保费，设定保额和保障时长
    function buyInsurance(uint256 _coverage, uint256 _duration) external payable {
        require(msg.value > 0, "Premium required");        // 必须支付保费
        require(_coverage > 0, "Coverage must be positive"); // 保额必须大于 0

        // 创建保单并存储到链上
        policies[nextPolicyId] = Policy({
            farmer: msg.sender,                             // 投保人
            premium: msg.value,                             // 保费 = 用户发送的 ETH
            coverage: _coverage,                            // 保额（理赔金额）
            startTime: block.timestamp,                     // 立即生效
            endTime: block.timestamp + _duration,           // 生效时间 + 时长 = 到期时间
            active: true,                                   // 保单激活
            claimed: false                                  // 未理赔
        });

        emit PolicyCreated(nextPolicyId, msg.sender, _coverage);
        nextPolicyId++; // ID 自增，准备给下一个保单用
    }

    // 申请理赔 - 农民认为发生了干旱，申请赔付
    function claimInsurance(uint256 _policyId) external {
        // 用 storage 引用保单，后续修改会直接写入链上
        Policy storage policy = policies[_policyId];

        // 四重验证
        require(policy.farmer == msg.sender, "Not policy owner");  // 只有投保人本人能申请
        require(policy.active, "Policy not active");                // 保单必须有效
        require(!policy.claimed, "Already claimed");                // 不能重复理赔
        require(block.timestamp <= policy.endTime, "Policy expired"); // 保单不能过期

        // 从预言机获取最新降雨量数据
        // 返回值有 5 个，我们只需要 rainfall（降雨量）和 updatedAt（更新时间）
        // 其他三个用逗号跳过（和 call 返回值省略 data 的写法一样）
        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();

        // 数据验证
        require(updatedAt > policy.startTime, "No recent weather data"); // 数据必须是保单生效后的
        require(rainfall >= 0, "Invalid rainfall data");                  // 降雨量不能为负数

        // 核心判断：降雨量是否低于干旱阈值
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            // 降雨量 < 20mm → 确认干旱 → 执行理赔
            policy.claimed = true;   // 标记已理赔
            policy.active = false;   // 保单失效

            // 支付理赔金给农民
            (bool success, ) = payable(msg.sender).call{value: policy.coverage}("");
            require(success, "Transfer failed");
            emit ClaimPaid(_policyId, msg.sender, policy.coverage);
        } else {
            // 降雨量 >= 20mm → 不符合理赔条件 → 拒绝
            revert("Claim conditions not met");
        }
    }

    // 获取当前天气数据 - 任何人都能查看当前降雨量
    // 方便前端展示或用户自行判断是否该申请理赔
    function getCurrentWeather() external view returns (int256 rainfall, uint256 timestamp) {
        (, int256 answer, , uint256 updatedAt, ) = weatherOracle.latestRoundData();
        return (answer, updatedAt);
    }

    // 检查理赔资格 - 在正式申请前先查一下能不能赔
    function checkClaimEligibility(uint256 _policyId) external view returns (bool eligible, string memory reason) {
        Policy storage policy = policies[_policyId];

        // 逐项检查，每一项不通过都返回具体原因
        if (!policy.active) return (false, "Policy not active");
        if (policy.claimed) return (false, "Already claimed");
        if (block.timestamp > policy.endTime) return (false, "Policy expired");

        (, int256 rainfall, , uint256 updatedAt, ) = weatherOracle.latestRoundData();

        if (updatedAt <= policy.startTime) return (false, "No recent weather data");
        if (rainfall < 0) return (false, "Invalid rainfall data");

        // 最终判断：够不够旱
        if (uint256(rainfall) < DROUGHT_THRESHOLD) {
            return (true, "Drought conditions met");     // 符合理赔条件
        } else {
            return (false, "Sufficient rainfall");        // 雨水充足，不符合
        }
    }
}