// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Day10 健身追踪合约
 * @dev 链上用户注册、体重管理、运动打卡功能
 */
contract SimpleFitnessTracker {
    // 所有者地址
    address public owner;

    // 用户资料结构体：姓名、体重、注册状态
    struct UserProfile {
        string name;
        uint256 weight;
        bool isRegistered;
    }

    // 运动记录结构体：运动类型、时长、距离、打卡时间
    struct WorkoutActivity {
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }

    // 核心存储：地址对应用户资料
    mapping(address => UserProfile) public userProfiles;
    // 地址对应用户的所有运动记录
    mapping(address => WorkoutActivity[]) public workoutHistory;
    // 统计：总运动次数、总运动距离
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;

    // 权限修饰符：仅已注册用户可调用
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    // 构造函数：设置合约部署者为所有者
    constructor() {
        owner = msg.sender;
    }

    // 事件定义
    event UserRegistered(address indexed user, string name, uint256 timestamp);
    event ProfileUpdated(address indexed user, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed user, string activity, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed user, string milestone, uint256 timestamp);

    /**
     * @dev 用户注册（仅允许注册一次）
     * @param _name 用户名
     * @param _weight 初始体重
     */
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        userProfiles[msg.sender] = UserProfile(_name, _weight, true);
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    /**
     * @dev 更新体重，减重≥5%触发里程碑事件
     * @param _newWeight 新体重
     */
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        
        // 减重达标判断：减重比例≥5%
        if (_newWeight < profile.weight && ((profile.weight - _newWeight) * 100) / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    /**
     * @dev 记录运动数据
     * @param _activityType 运动类型
     * @param _duration 运动时长
     * @param _distance 运动距离
     */
    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance) public onlyRegistered {
        WorkoutActivity memory newWorkout = WorkoutActivity(
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );

        workoutHistory[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;

        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);
    }

    // ------------------- 只读查询函数 -------------------
    /**
     * @dev 查询当前用户的完整资料
     */
    function getUserProfile() public view returns (string memory, uint256, bool) {
        UserProfile memory profile = userProfiles[msg.sender];
        return (profile.name, profile.weight, profile.isRegistered);
    }

    /**
     * @dev 查询当前用户的所有运动记录
     */
    function getWorkoutHistory() public view returns (WorkoutActivity[] memory) {
        return workoutHistory[msg.sender];
    }

    /**
     * @dev 查询当前用户运动统计数据
     */
    function getWorkoutStats() public view returns (uint256, uint256) {
        return (totalWorkouts[msg.sender], totalDistance[msg.sender]);
    }
}