//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker{
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
    }
    struct WorkoutActivity{
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp; 
    }

    mapping (address=>UserProfile) public UserProfiles;
    mapping (address=>WorkoutActivity[])public WorkoutActivities;
    mapping (address=>uint256)public totalWorkouts;
    mapping (address=>uint256)public totalDistances;

    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string ActivityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    modifier onlyRegistered{
        require(UserProfiles[msg.sender].isRegistered,"User is not registered");
        _;
    }
    function registerUser(string memory _name, uint256 _weight) public{
        require(!UserProfiles[msg.sender].isRegistered, "User already registered");
        UserProfiles[msg.sender]=UserProfile({
            name: _name,
            weight:_weight,
            isRegistered: true
        });
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    function updateWeight(uint256 _newWeight) public onlyRegistered{
        UserProfile storage profile = UserProfiles[msg.sender];
        if(_newWeight < profile.weight && (profile.weight-_newWeight)*100/profile.weight>=5){
            emit MilestoneAchieved(msg.sender, "Weight goal achieved", block.timestamp);
        }
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance)public onlyRegistered{
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        WorkoutActivities[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistances[msg.sender]+= _distance;
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);

        if(totalWorkouts[msg.sender]==10){
            emit MilestoneAchieved(msg.sender, "10 workout completed", block.timestamp);
        }
        else if(totalWorkouts[msg.sender]==50){
            emit MilestoneAchieved(msg.sender, "50 workout completed", block.timestamp);
        }
        if(totalWorkouts[msg.sender]>=10000 && totalDistances[msg.sender]-_distance<10000){
            emit MilestoneAchieved(msg.sender, "10K total distance", block.timestamp);
        }
    }
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return WorkoutActivities[msg.sender].length;
    }
}
