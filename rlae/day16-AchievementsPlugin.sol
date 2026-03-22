// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//跟踪每个玩家最近解锁的最新成就
contract AchievementsPlugin {
    // user => achievement string
    mapping(address => string) public latestAchievement;

    // Set achievement for a user (called by PluginStore) 更新特定用户的最新成就字符串
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // Get achievement for a user
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}