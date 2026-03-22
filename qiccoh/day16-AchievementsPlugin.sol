// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
    //  跟踪每个玩家最近解锁的最新成就
    mapping(address => string) public latestAchievement;//address是玩家的钱包,string是成就的名称

    // 更新特定用户的最新成就字符串
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // 获取特定用户解锁的最新成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}