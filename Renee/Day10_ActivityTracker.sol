// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    struct UserProfile {
        string name;
        uint256 weight; //kg
        bool isRegistered;
    }
    struct WorkoutActivity {
        string activityType;
        uint256 duration; //seconds
        uint256 distance; //meters
        uint256 timestamp; //activity发生时间
    }

    mapping (address => UserProfile) public userProfiles; //为每个用户（通过ta们的地址）存储一份个人资料
    mapping (address => WorkoutActivity[]) public workoutHistory; //为每个用户保存一个锻炼日志数组
    mapping (address => uint256) public totalWorkouts; //跟踪每个用户记录了多少次锻炼
    mapping (address => uint256) public totalDistance; //跟踪用户覆盖的总距离

    //声明事件
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp); //indexed: 参数变得可搜索。一个事件中最多只能索引三个参数
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered == true, "User not registered.");
        _;
    }

    
    function registerUser(string memory _name, uint256 _weight) public {
        require(userProfiles[msg.sender].isRegistered == false, "User already registered.");

        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, block.timestamp); //发出事件会消耗一点 Gas（因为日志被写入区块链），但比在链上存储数据便宜得多。事实上，发出事件是智能合约暴露数据最节省 Gas 的方式之一。这就是为什么经常将其用于前端更新、分析以及任何不需要永久存储在状态中的事情。
    }
    function updateWeight(uint _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender]; //创建一个指向存储在区块链上的用户个人资料的引用（reference）,修改链上实际存在的个人资料而非 memory

        if (_newWeight < profile.weight && (profile.weight - _newWeight) / profile.weight * 100 >= 5)
        {
            emit MilestoneAchieved(msg.sender,"Weight Goal Reached!", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    function logWorkout(
        string memory _activityType,
        uint _duration,
        uint _distance
    ) public onlyRegistered {
        //create new activity
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        //add to user's workout history
        workoutHistory[msg.sender].push(newWorkout);

        //update total stats
        totalWorkouts[msg.sender] ++;
        totalDistance[msg.sender] += _distance;

        //emit workout logged event
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
            );
        
        //check for workout count milestones
        if (totalWorkouts[msg.sender] == 10) 
        {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed!", block.timestamp);
        } 
        else if (totalWorkouts[msg.sender] == 50) 
        {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed!", block.timestamp);
        }

        //check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance <100000)
        {
            emit MilestoneAchieved(msg.sender, "100K Total Distance!", block.timestamp);
        }
    }

    function getUserWorkoutCount() public view onlyRegistered returns(uint256) {
        return totalWorkouts[msg.sender]; //return workoutHistoey[msg.sender].length;
    }
    
}