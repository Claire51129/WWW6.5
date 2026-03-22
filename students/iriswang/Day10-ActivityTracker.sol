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
    }
    
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
    
    // ============ 新增功能：删除锻炼记录 ============
    function deleteWorkout(uint256 index) public onlyRegistered {
        require(index < workoutHistory[msg.sender].length, "Invalid index");
        
        WorkoutActivity storage workout = workoutHistory[msg.sender][index];
        
        // 从总距离中减去被删除记录的距离
        totalDistance[msg.sender] -= workout.distance;
        
        // 将最后一个元素移到被删除的位置，然后pop（保持数组紧凑）
        uint256 lastIndex = workoutHistory[msg.sender].length - 1;
        if (index != lastIndex) {
            workoutHistory[msg.sender][index] = workoutHistory[msg.sender][lastIndex];
        }
        workoutHistory[msg.sender].pop();
        
        // 减少总锻炼次数
        totalWorkouts[msg.sender]--;
    }
    // ==============================================
    
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
