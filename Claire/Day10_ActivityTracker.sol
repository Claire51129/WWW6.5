//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {//开始部署合约
    address public owner;
    
    // User profile struct
    struct UserProfile {
        string name;
        uint256 weight; 
        bool isRegistered;
    }//把结构体？多个相关数据打包成一个新类型
    
    
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;    // in seconds
        uint256 distance;    // in meters
        uint256 timestamp;   
    }//结构体，记录一次运动的所有信息
    
   
    mapping(address => UserProfile) public userProfiles;
    
    mapping(address => WorkoutActivity[]) private workoutHertory;
    //mapping的值是一个数组
//数组里每个元素是WorkoutActivity结构体
//记录每个人的运动历史
   
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    //记录链上发生的事
//前端可以监听
//indexed = 可以按这个字段搜索
//当你将一个参数标记为 indexed 时，你使它变得可搜索。这意味着你可以在前端根据该特定值筛选日志。
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
    //如果没有 indexed，你就必须扫描每一个事件日志并手动检查——效率低下且速度缓慢。
    //在 Solidity 中，一个 event 就像定义一个自定义的日志格式。当你的合约中发生重要事件时，你可以 emit（发出）一个这样的事件，它将被记录在交易日志中。
    //事件不会影响你的合约状态——它们只是合约用来表达“嘿，刚刚发生了点事”并发送相关细节的一种方式。
//然后，这些日志可以被你的前端捕获，以显示消息、更新用户界面或实时触发操作。
        address indexed userAddress, //谁进行了锻炼。
        string activityType, //他们做了什么类型的活动
        uint256 duration, //锻炼持续时间
        uint256 distance, //长度
        uint256 timestamp//事件发生时间
    );
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    //合约主人
    // Register a new user
    function registerUser(string memory _name, uint256 _weight) public {//注册新用户
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // Emit registration event
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }//发个事件通知大家，有人注册了！！！！！！！！！！！！！
    
    // Update user weight
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        //profile 就是指向链上数据的遥控器
        //直接改链上的数据
        //storage = 直接操作链上数据（可修改）
        //不加storage默认是memory（拷贝）
        // Check if significant weight loss (5% or more)
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        //检查体重成就
        profile.weight = _newWeight;
        //更新体重
        // Emit profile update event
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }//发布事件：有人更新体重了
    
    // Log a workout activity
    function logWorkout(
    //记录一次运动
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // Create new workout activity创建一个运动记录结构体
        WorkoutActivity memory newWorkout = WorkoutActivity({
        //把运动记录存进历史数组
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });//更新统计的数据
        
        // Add to user's workout hertory
        workoutHertory[msg.sender].push(newWorkout);
        
        // Update total stats
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // Emit workout logged event
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );//发通知：有人运动了，以及运动的详情
        
        // Check for workout count milestones
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        //检查次数成就，10次和50次
        // Check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    //检查距离成就
    // Get the number of workouts for a user
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHertory[msg.sender].length;
    }//用于自己运动了几次
}