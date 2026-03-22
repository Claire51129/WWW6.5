//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AchievementPlugin{

    //user => achievement string
    mapping(address => string) public LatestAchievement;

    //set achievement
    function setAchievement(address _user, string memory _achievement) public {
        LatestAchievement[_user] = _achievement;
    }

    //view achievement
    function getAchievement(address _user) public view returns(string memory){
        return   LatestAchievement[_user];
    }
}

//0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8