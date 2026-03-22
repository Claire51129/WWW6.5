//SPDX-License-Identifier：MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker{
    struct UserProfiles{
        string name;
        uint256 weight; 
        bool isRegistered;
    }
    struct WorkoutActivity{
        string activityType;
        uint256 duration;//in senconds
        uint256 distance;//in meters
        uint256 timestamp;//发生时间
    }

    mapping(address=>UserProfiles) public userProfiles;
    mapping(address=>WorkoutActivity[]) private workoutHistory;
    mapping(address=>uint256) public totalWorkouts;//每个用户记录了多少次锻炼
    mapping(address=>uint256) public totalDistance;//用户覆盖的总距离

    //声明事件，前端才能做出反应
    //定义自定义的日志格式   
    event UserRegistered(
        address indexed userAddress, 
        string name, 
        uint256 timestamp);
    event ProfileUpdated(
        address indexed userAddress, 
        uint256 newWeight, 
        uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress,
        //将一个参数标记为 indexed 时，你使它变得可搜索,一个事件最多可搜索3个
        string activityType,
        uint256 duration,
        uint256 distance,
        uint256 timestamp);
    event MilestoneAchieved(
        address indexed userAddress, 
        string milestone, 
        uint256 timestamp);
    
     
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    //注册新用户
    function registerUser(string memory _name,uint256 _weight) public{
        require(!userProfiles[msg.sender].isRegistered,"user already registerd");

        userProfiles[msg.sender]=UserProfiles(
            {
                name:_name,
                weight:_weight,
                isRegistered:true
            }
        );
        //新知识:按照UserRegistered的格式发送日志
        emit UserRegistered(msg.sender,_name,block.timestamp);
    }
    //更新体重
    function updateWeight(uint256 _newWeight) public onlyRegistered{
        UserProfiles storage profile=userProfiles[msg.sender]; 
        //用storage：不要在内存中创建副本，而是直接指向 EVM 账本（硬盘）上的那个位置
        if(_newWeight<profile.weight &&(profile.weight-_newWeight)*100/profile.weight>=5){
            emit MilestoneAchieved(msg.sender,"Weight Goal Reached",block.timestamp);
        }

        profile.weight=_newWeight;
        emit ProfileUpdated(msg.sender,_newWeight,block.timestamp);
    }
    //追踪每一次训练、跑步、骑行
    function logWorkout(string memory _activityType,uint256 _duration,uint256 _distance)public onlyRegistered{
        WorkoutActivity memory newWorkout=WorkoutActivity({
        activityType:_activityType,
        duration:_duration,//in senconds
        distance:_distance,//in meters
        timestamp:block.timestamp//发生时间
        });

        workoutHistory[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;

        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);
        
        //发送达成成就的日志
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } 
        else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
        emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
//新知识：
//两个主要的数据位置：`storage` 和 `memory`。
//`storage` 是持久的——它存在于区块链上，读/写都需要消耗 Gas。
//`memory` 是临时的——它只在函数调用期间存在，而且便宜得多。
        function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
            return workoutHistory[msg.sender].length;
        }
}