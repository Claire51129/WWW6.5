//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner;    // 记录谁创建了这个合约（APP管理员）

    // User profile struct 创建用户资料信息
    struct UserProfile {
        string name;
        uint256 weight;
        bool isRegistered;
    }


    // 运动记录卡
    struct WorkoutActivity {
        string activityType;    // 运动类型eg跑步、游泳、单车etc.
        uint256 duration;    // in seconds
        uint256 distance;    // in meters
        uint256 timestamp;
    }


    // 用户数据库：钱包地址 → 用户资料
    mapping(address => UserProfile) public userProfiles;

    // 每个人的运动历史：钱包地址 → 运动纪录列表
    mapping(address => WorkoutActivity[]) private workoutHistory;


    // 记录每个人运动了多少次：钱包地址 → 运动总次数
    mapping(address => uint256) public totalWorkouts;
    
    
    // 记录每个人跑了多少距离：钱包地址 → 距离
    mapping(address => uint256) public totalDistance;    // in meters


    // 事件广播
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);    // sb.注册了
    event ProfileUpdated(address indexed userAddress, uint256 distance, uint256 timestamp);    // sb.更新资料了
    event WorkoutLogged(    // sb.记录了一次运动
        address indexed userAddress,
        string activityType,
        uint256 duration,     // in minutes
        uint256 distance,    // in meters
        uint256 timestamp
    );
    // 达成成就
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    constructor() {    // 当合约创建时，创建者=owner
        owner = msg.sender;    // 谁发起交易
    }

    modifier onlyRegistered() {    // 权限控制：只有注册用户才能使用
        require(userProfiles[msg.sender].isRegistered, "User is not registered");
        _;
    }

    //Register a new user 新用户注册
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User is already registered");    //检查是否已注册过

        userProfiles[msg.sender] = UserProfile({    // 创建用户资料卡
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        //Emit registration event 广播消息：sb.注册成功
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    //Update user's weight 更新体重信息
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];    //找到自己的用户资料

        //Check if significant weight loss (5% or more)
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >=5) {    // 检查体重是否下降5%
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);    //广播：达成减重目标
        }

        profile.weight = _newWeight;    // 更新体重

        //Emit profile update event
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    // Log a workout activity 记录运动
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        //Create a new workout activity 创建一条新的运动记录，eg跑步30min5000mXX时间戳
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        //Add to user's workout history
        workoutHistory[msg.sender].push(newWorkout);

        //Update total status 
        totalWorkouts[msg.sender]++;    // 运动次数+1
        totalDistance[msg.sender] += _distance;    // 总距离增加

        //Emit workout logged event 广播：记录了一次运动
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );

        //Check for workout count milestones 
        if (totalWorkouts[msg.sender] == 10) {    // 如果运动达到10次时，广播
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {    // 当总运动达到50次时，广播
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }

        //Check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);    // 当总距离达到100km时广播
        }
    }

    //Get the number of workouts for a user 用于查询你遇到弄了多少次
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}





// 简单健身记录系统
// 1 注册用户
// 2 更新体重
// 3 记录运动
// 4 统计运动数据
// 5 达到目标给奖励