//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AchievementPlugin
 * @dev 成就插件，用于存储和管理玩家的成就信息
 * 该合约作为插件集成到游戏系统中，记录玩家解锁的成就
 */
contract AchievementPlugin {
    // 存储玩家最新成就的映射表
    // key: 玩家地址 -> value: 成就名称
    mapping(address => string) public latestAchievement;

    /**
     * @dev 设置玩家的成就
     * @param player 玩家地址
     * @param achievementName 成就名称
     */
    function setAchievement(address player, string memory achievementName ) public {
        latestAchievement[player] = achievementName;
    }

    /**
     * @dev 获取玩家的成就
     * @param user 用户地址
     * @return 成就名称
     * @notice 注意：当前实现只返回最新成就，如有需要可扩展为数组存储多个成就
     */
    function getAchievement(address user) public view returns (string memory) {
        // BUG FIX: 原代码使用了未定义的 player 变量，应改为 user
        return latestAchievement[user];
    }
}