// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
    // 存储每个地址的最新成就
    mapping(address => string) public latestAchievement;
    
    // 设置成就（修改状态）
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }
    
    // 获取成就（只读）
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}
