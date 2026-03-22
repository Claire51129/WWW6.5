//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//简单的健身追踪器，用户可以注册、记录锻炼活动、更新体重，并且当达到特定里程碑时触发事件。
contract SimpleFitnessTracker {
    address public owner;
    
    //struct 结构体是 Solidity 中的一种自定义数据类型，允许我们将多个相关的变量组合在一起形成一个单一的复杂数据结构。在这个合约中，我们定义了两个结构体：UserProfile 和 WorkoutActivity。
    // 用户档案结构体，包含姓名、体重和注册状态
    struct UserProfile {
        string name;
        uint256 weight; 
        bool isRegistered;
    }
    
    // 锻炼活动结构体，包含活动类型、持续时间、距离和时间戳
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;    // in seconds
        uint256 distance;    // in meters
        uint256 timestamp;   
    }
    
   // 用户地址映射到用户档案
    mapping(address => UserProfile) public userProfiles;
    // 用户地址映射到锻炼活动历史记录
    mapping(address => WorkoutActivity[]) private workoutHistory;
    // 用户地址映射到总锻炼次数和总距离
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    // 事件定义，用于记录用户注册、档案更新、锻炼记录和里程碑达成 
    //event 事件是 Solidity 中的一种特殊类型，用于在区块链上记录特定的活动或状态变化。当事件被触发时，它会将相关信息记录在交易日志中，这些日志可以被外部应用程序监听和查询。通过使用事件，我们可以实现更高效的数据跟踪和用户交互，而不需要频繁地查询合约的状态变量。
    //在 Solidity 中，一个 event 就像定义一个自定义的日志格式。当你的合约中发生重要事件时，你可以 emit（发出）一个这样的事件，它将被记录在交易日志中。
    //indexed 关键字允许我们在事件日志中对这些字段进行过滤和查询，这对于跟踪特定用户的活动非常有用。
    //UserRegistered 事件在用户注册时触发，记录用户地址、姓名和时间戳。这有助于跟踪新用户的注册情况，并且当用户注册时，可以触发欢迎消息或其他相关事件。
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    //ProfileUpdated 事件在用户更新体重时触发，记录用户地址、新体重和时间戳。这有助于跟踪用户的体重变化，并且当用户达到特定的体重目标时，可以触发里程碑事件。
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    //WorkoutLogged 事件在用户记录锻炼活动时触发，记录用户地址、活动类型、持续时间、距离和时间戳。这有助于跟踪用户的锻炼历史，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    //MilestoneAchieved 事件在用户达到特定里程碑时触发，记录用户地址、里程碑描述和时间戳。这有助于激励用户继续锻炼，并且当用户达到重要的健身目标时，可以触发奖励或其他相关事件。
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // 用户注册函数，用户需要提供姓名和初始体重。注册后会触发 UserRegistered 事件。
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 注册成功后触发事件，记录用户地址、姓名和时间戳。这有助于跟踪新用户的注册情况，并且当用户注册时，可以触发欢迎消息或其他相关事件。
        //emit 关键字用于触发事件，UserRegistered 是事件的名称，括号内是事件参数。indexed 关键字允许我们在事件日志中对这些字段进行过滤和查询，这对于跟踪特定用户的活动非常有用。
        //发出事件确实会消耗一点 Gas（因为日志被写入区块链），但**它们比在链上存储数据便宜得多**。
        //事实上，发出事件是智能合约暴露数据最节省 Gas 的方式之一。这就是为什么我们经常将它们用于前端更新、分析以及任何不需要永久存储在状态中的事情。
        //block.timestamp 是一个全局变量，返回当前区块的时间戳（以秒为单位）。通过记录时间戳，我们可以知道用户注册的确切时间，这对于分析用户行为和活动模式非常有帮助。
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // 更新体重函数，用户可以更新他们的体重。如果体重下降了5%或更多，将触发一个里程碑事件。无论体重是否达到里程碑，都会触发 ProfileUpdated 事件，记录新的体重和时间戳。这有助于跟踪用户的体重变化，并且当用户达到特定的体重目标时，可以触发里程碑事件。
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        //storage 关键字表示我们正在引用存储中的数据，而不是内存中的数据。通过使用 storage，我们可以直接修改用户档案中的体重信息，而不需要创建一个新的副本。这有助于节省 Gas 并且确保我们对用户档案的修改是持久的。
        //使用 memory，我们将只是在一个临时副本上工作——我们所做的任何更改都将在函数结束时被丢弃
        UserProfile storage profile = userProfiles[msg.sender];
        
        // Check if significant weight loss (5% or more)
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight;
        
        // Emit profile update event
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // 记录锻炼活动函数，用户可以记录他们的锻炼活动，包括活动类型、持续时间和距离。每次记录都会触发 WorkoutLogged 事件，记录活动详情和时间戳。这有助于跟踪用户的锻炼历史，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // Create new workout activity
        //创建了一个新的 WorkoutActivity 实例，并将其添加到用户的锻炼历史记录中。这有助于跟踪用户的锻炼活动，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        //将新的锻炼活动添加到用户的锻炼历史记录中。这有助于跟踪用户的锻炼活动，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
        workoutHistory[msg.sender].push(newWorkout);
        
        //更新用户的总锻炼次数和总距离。这有助于跟踪用户的整体锻炼进展，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
        //++运算符将用户的总锻炼次数增加1，表示用户又完成了一次锻炼活动。+=运算符将用户的总距离增加当前锻炼活动的距离，表示用户在整体锻炼进展中又增加了相应的距离。这有助于跟踪用户的整体锻炼进展，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        //触发 WorkoutLogged 事件，记录用户地址、活动类型、持续时间、距离和时间戳。这有助于跟踪用户的锻炼历史，并且当用户达到特定的锻炼里程碑时，可以触发里程碑事件。
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        //如果用户的总锻炼次数达到了10次或50次，将触发 MilestoneAchieved 事件，记录里程碑描述和时间戳。
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        //如果用户的总距离达到了100公里，将触发 MilestoneAchieved 事件，记录里程碑描述和时间戳。
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // 获取用户锻炼历史函数，用户可以查看他们的锻炼活动历史记录。这个函数是 view 类型的，因为它只读取数据而不修改状态变量。
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}