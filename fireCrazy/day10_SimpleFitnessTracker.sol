// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker { 

    // --- 1. 数据结构 (Structs) ---
    struct UserProfile { 
        string name;
        uint256 weight; // 单位：公斤
        bool isRegistered;
    }

    struct WorkoutActivity { 
        string activityType;
        uint256 duration; // 单位：秒
        uint256 distance; // 单位：米
        uint256 timestamp;
    }

    // --- 2. 状态变量 (Mappings) --- 
    mapping(address => UserProfile) public userProfiles; // 存放个人资料 
    mapping(address => WorkoutActivity[]) private workoutHistory; // 存放历史记录数组 
    mapping(address => uint256) public totalWorkouts; // 总锻炼次数
    mapping(address => uint256) public totalDistance; // 总运动距离

    // --- 3. 事件大喇叭 (Events) --- 
    // 注意这里带 indexed 的 userAddress，方便网页专门搜索某个人的记录 
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    // --- 4. 保安亭 (Modifier) ---
    modifier onlyRegistered() { 
        require(userProfiles[msg.sender].isRegistered, "User not registered"); 
        _;
    }

    // --- 5. 核心功能 ---

    // 功能 A：注册成为会员
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered"); 
        
        userProfiles[msg.sender] = UserProfile({
            name: _name, 
            weight: _weight, 
            isRegistered: true 
        });
        
        // 拿起大喇叭广播：有人注册啦！ 
        emit UserRegistered(msg.sender, _name, block.timestamp); 
    }

    // 功能 B：更新体重（包含减肥里程碑逻辑）
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        // 注意：这里用 storage 直接拿到链上原始数据的“钥匙”，而不是拷贝临时数据
        UserProfile storage profile = userProfiles[msg.sender]; 
        
        // 智能教练逻辑：如果体重下降超过 5%，颁发里程碑成就！
        if (_newWeight < profile.weight && ((profile.weight - _newWeight) * 100 / profile.weight >= 5)) { 
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight; // 永久保存新体重 
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp); // 广播体重更新 
    }

    // 功能 C：记录一次锻炼（包含锻炼里程碑逻辑）
    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance) public onlyRegistered { 
        
        // 注意：这里用 memory，因为这只是个临时包裹，塞进历史记录就不要了，省 Gas！
        WorkoutActivity memory newWorkout = WorkoutActivity({ 
            activityType: _activityType, 
            duration: _duration, 
            distance: _distance, 
            timestamp: block.timestamp 
        });
        
        // 把包裹塞进个人的锻炼历史数组里 
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新总数据 
        totalWorkouts[msg.sender]++; 
        totalDistance[msg.sender] += _distance;
        
        // 广播：有人刚做完运动！ 
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp); 

        // 智能教练逻辑：检查是否达到 10 次或 50 次锻炼的里程碑
        if (totalWorkouts[msg.sender] == 10) { 
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp); 
        } else if (totalWorkouts[msg.sender] == 50) { 
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp); 
        }

        // 智能教练逻辑：检查总距离是否突破 100,000 米 (100公里) 
        if (totalDistance[msg.sender] >= 100000 && (totalDistance[msg.sender] - _distance) < 100000) { 
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp); 
        }
    }

    // 功能 D：查询总锻炼次数 
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return totalWorkouts[msg.sender];
    }
}
