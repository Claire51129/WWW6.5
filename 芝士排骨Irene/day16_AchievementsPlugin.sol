// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 成就插件合约 - 一个可以被 PluginStore 动态调用的独立插件
contract AchievementsPlugin {

    // 玩家地址 => 最新成就描述
    // 例如：0xABC => "首次通关"，0xDEF => "连续签到7天"
    mapping(address => string) public latestAchievement;

    // 设置成就 - 给某个玩家记录一条成就
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // 获取成就 - 查询某个玩家的最新成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}