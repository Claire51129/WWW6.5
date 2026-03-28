//这个小东西专门用来追踪成就

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AchievementsPlugin {
//用映射关联一下
    mapping(address => string) public latestAchievement;
//更新一下，你刚刚达成成就哟，关联，简单
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }
//获取，插旗
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}
