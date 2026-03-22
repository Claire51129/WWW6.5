// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner;
    
    // 用户资料结构体
    struct UserProfile {
        string name; 
        uint256 weight; 
        bool isRegistered;  // 是否已经注册
    }
    
    // 运动记录结构体
    struct WorkoutActivity {
        string activityType; // 运动类型（跑步、骑行等）
        uint256 duration;    // 运动持续时间（秒）
        uint256 distance;    // 运动距离（米）
        uint256 timestamp;   // 记录时间
    }
    
    // 为每个用户（通过他们的地址）存储一份个人资料
    mapping(address => UserProfile) public userProfiles;
    
    // 为每个用户保存一个锻炼日志数组
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
    // 跟踪每个用户记录了多少次锻炼
    mapping(address => uint256) public totalWorkouts;
    
    // 跟踪用户覆盖的总距离
    mapping(address => uint256) public totalDistance;
    
    
    // 声明事件 用户注册
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    
    // 声明事件 用户更新资料
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    
    // 声明事件 用户记录运动
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    
    // 声明事件 用户达到某个里程碑
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    
    // 构造函数
    constructor() {
        owner = msg.sender;
    }
    
    
    // Modifier:确保调用者已经注册
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    
    // 注册用户
    function registerUser(string memory _name, uint256 _weight) public {
        
        // 确保用户还没有注册
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        // 创建用户资料
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 触发注册事件
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    
    // 更新体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        
        // 访问用户的个人资料
        UserProfile storage profile = userProfiles[msg.sender];
        
        // 检查体重里程碑
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        // 更新体重
        profile.weight = _newWeight;
        
        // 触发资料更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    
    // 记录运动
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        
        // 创建新的运动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        // 保存到用户历史记录
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新总运动次数和距离
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 触发运动记录事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 检查运动次数里程碑
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } 
        else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检查距离里程碑（100km = 100000米）
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    
    // 获取用户的运动次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }

}