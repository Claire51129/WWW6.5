// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//成就插件：用于存储每位玩家的最新解锁的成就 ——比如"First Blood", "Master Collector", or "Top 1%"

//使用标准的设置器模式，以便 PluginStore 可以将其调用委托出去
contract AchievementsPlugin {
    // user => achievement string是成就的名称（例如"First Kill" 或 "Treasure Hunter"）
    mapping(address => string) public latestAchievement;

    // Set achievement for a user (called by PluginStore)更新特定用户的最新成就
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // Get achievement for a user获取特定用户解锁的最新成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}