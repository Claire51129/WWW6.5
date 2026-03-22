//SPDX-License-Identifier: MIT
// MIT开源许可证声明
pragma solidity ^0.8.0;
// 指定编译器版本：^0.8.0（兼容0.8.x，不兼容0.9.0+）

contract SimpleFitnessTracker {
    // 合约所有者地址（权限管理）
    address public owner;
    
    // 用户资料结构体：存储姓名、体重、注册状态
    struct UserProfile {
        string name;        // 姓名
        uint256 weight;     // 体重
        bool isRegistered;  // 注册标记
    }
    
    // 运动记录结构体：类型/时长(秒)/距离(米)/时间戳
    struct WorkoutActivity {
        string activityType; // 运动类型（跑步/游泳等）
        uint256 duration;    // 时长（秒）
        uint256 distance;    // 距离（米）
        uint256 timestamp;   // 记录时间戳
    }
    
    // 地址→用户资料：存储注册用户基本信息
    mapping(address => UserProfile) public userProfiles;
    
    // 地址→运动记录数组：存储用户所有运动历史（私有）
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
    // 地址→总运动次数
    mapping(address => uint256) public totalWorkouts;
    // 地址→总运动距离（米）
    mapping(address => uint256) public totalDistance;
    
    // 事件：记录关键操作，供前端监听/日志查询
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp); // 用户注册
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp); // 资料更新
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    ); // 运动记录
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp); // 里程碑达成
    
    // 构造函数：部署时设部署者为合约所有者
    constructor() {
        owner = msg.sender;
    }
    
    // 修饰器：仅已注册用户可调用
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // 用户注册：新用户录入姓名、体重完成注册
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered"); // 防重复注册
        
        // 存储新用户资料
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        emit UserRegistered(msg.sender, _name, block.timestamp); // 触发注册事件
    }
    
    // 更新体重：已注册用户修改体重，减重≥5%触发里程碑
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender]; // 获取用户资料引用
        
        // 检测减重≥5%的里程碑
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight; // 更新体重
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp); // 触发资料更新事件
    }
    
    // 记录运动：已注册用户录入运动类型、时长、距离
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // 创建运动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        workoutHistory[msg.sender].push(newWorkout); // 新增至运动历史
        // 更新统计数据
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp); // 触发运动记录事件
        
        // 检测运动次数里程碑（10/50次）
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检测距离里程碑（100公里=100000米）
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // 获取当前用户的运动记录总数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}