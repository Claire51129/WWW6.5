// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract activityTracker {
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
    }
    struct workoutActivity {
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;

    }
    mapping (address=>UserProfile) public userProfiles;// 人对应的profile;
    mapping (address=>workoutActivity[]) private workoutHistory;// 锻炼数据数组
    mapping (address=>uint256) public totalWorkouts;
    mapping (address=>uint256) public totalDistances;
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);// indexed, make it easy to find, cost more ga, only 3 param can be indexed
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);// 
    event MilestoneAchieved(address indexed userAddress, string infromation,uint256 timestamp);
    modifier onlyRegistered(){
        require (userProfiles[msg.sender].isRegistered,"user not registered");
        _;
    }
    function registerUser (string memory _name, uint256 _weight) public { //user input name and weight
    require (!userProfiles[msg.sender].isRegistered,"user already registered"); // 确保没有注册
    userProfiles[msg.sender]=UserProfile({ //加入新用户信息，把注册状态标记为true
        name: _name,
        weight:_weight,
        isRegistered: true
    });
    emit UserRegistered(msg.sender, _name, block.timestamp); // 告诉区块链消息

    }
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];//创建一指向存储在区块链上的用户个人资料的引用（reference）
        if (_newWeight<profile.weight && (profile.weight-_newWeight)/profile.weight*100>=5){
            emit MilestoneAchieved(msg.sender, "Weight goad achieved ", block.timestamp);
            profile.weight=_newWeight;
            emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);//让外部世界知道用户的体重已经改变,有助于前端刷新用户统计数据或重新计算进度条。
        }

    }
    function logworkout(
        string memory _activityType,// ;?,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        workoutActivity memory newworkout = workoutActivity({ //创建一个结构体for 输入的数据
        activityType:_activityType,
        duration:_duration,
        distance:_distance,
        timestamp:block.timestamp
        });
        workoutHistory[msg.sender].push(newworkout); // input sender 's new workout
        totalWorkouts[msg.sender]++;
        totalDistances[msg.sender]+=_distance;
        emit WorkoutLogged(
            msg.sender,
            _activityType, 
            _duration, 
            _distance,
            block.timestamp
        );
        if (totalWorkouts[msg.sender]==10){
        emit MilestoneAchieved(msg.sender,"10 workouts completed",block.timestamp);
        }
        else if (totalWorkouts[msg.sender]==50){
        emit MilestoneAchieved(msg.sender,"50 workouts completed",block.timestamp);
        }
        if (totalDistances[msg.sender]>=100000 &&totalDistances[msg.sender]-_distance<100000 ){
        emit MilestoneAchieved(msg.sender,"100k distance completed",block.timestamp);
        }
    }
    function getworkoutCount()public view onlyRegistered returns(uint256){
        return workoutHistory[msg.sender].length;// 用户记录的锻炼数
    }
}
