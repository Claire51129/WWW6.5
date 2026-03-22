// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker {
    // 结构体定义
    struct UserProfile {
        string name;
        uint256 weight;
        bool isRegistered;
    }
    
    struct WorkoutActivity {
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }//分成两个结构体，一个储存静态的数据，一个组存动态的数据。另外，构造函数是实现初始化，后续可以通过onlyowner的方式来调用结构体式表格格式，可以设计成多种。
    
    // 状态变量
    mapping(address => UserProfile) public userProfiles;
    mapping(address => WorkoutActivity[]) private workoutHistory;
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    // 事件
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    // 修饰符
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // 注册用户
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "Already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // 更新体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // 记录锻炼
    function logWorkout(
        string memory _activityType, 
        uint256 _duration, 
        uint256 _distance
    ) public onlyRegistered {
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        workoutHistory[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);
        
        // 检查里程碑
        checkMilestones();
    }
    
    // 检查里程碑
    function checkMilestones() private {
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 workouts completed!", block.timestamp);
        }
        
        if (totalDistance[msg.sender] >= 100000) {  // 100km = 100000m
            emit MilestoneAchieved(msg.sender, "100km distance achieved!", block.timestamp);
        }
        
        if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 workouts completed!", block.timestamp);
        }
    }
    
    // 查询函数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return totalWorkouts[msg.sender];
    }
    
    function getWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory) {
        return workoutHistory[msg.sender];
    }
    
    function getLatestWorkout() public view onlyRegistered returns (WorkoutActivity memory) {
        require(workoutHistory[msg.sender].length > 0, "No workouts yet");
        uint256 lastIndex = workoutHistory[msg.sender].length - 1;
        return workoutHistory[msg.sender][lastIndex];
    }
}