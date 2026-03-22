// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin 
{
    // 跟踪每个玩家最近解锁的最新成就,string是成就名称
    mapping(address => string) public latestAchievement;

    // Set achievement for a user (called by PluginStore)
    function setAchievement(address user, string memory achievement) public 
    {
        latestAchievement[user] = achievement;
    }

    // Get achievement for a user
    //这个 getter 是明确定义的，为了未来兼容性和清晰性
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}
