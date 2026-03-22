// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin{
    mapping(address => string) public latestAchievement;
    //address玩家的钱包
    //自动免费创建getter函数 latestAchievement(address）--> string

    function setAchievement(address user, string memory achievement) public{
        latestAchievement[user] = achievement;
    }

    function getAchievement(address user) public view returns (string memory){
        return latestAchievement[user];
    }
}