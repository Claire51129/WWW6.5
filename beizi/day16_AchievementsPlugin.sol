// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AchievementsPlugin{
    //跟踪每个玩家最近解锁的最新成就
    mapping(address => string) public latestAchievement;
    
    //用于设置或更新玩家最新的成就
    function setAchievement(address user, string memory achievement) public {
    latestAchievement[user] = achievement;
}

//用于“查看”或“查询”已经获得的成就
function getAchievement(address user) public view returns (string memory) {
    return latestAchievement[user];
}
}
