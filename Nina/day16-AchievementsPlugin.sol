/** 成就插件 — 玩家里程碑的附加逻辑
这份合同是一个**插件** ，用于存储每位玩家的**最新解锁的成就** ——比如`"First Blood"`, `"Master Collector"`, or `"Top 1%"`。
它的逻辑简单且专注——它是一个  **隔离模块** ，负责一件事情： **追踪成就** 。
它被设计为通过像 `runPlugin(...)` 这样的函数由 `PluginStore` 合约使用。
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AchievementsPlugin {
    // user => achievement string
    mapping(address => string) public latestAchievement; // 它被标记为 public ，这意味着 Solidity 会自动免费创建一个 getter 函数。但下方我们还是自定义了 getAchievement 函数，提供了更大的灵活性（未来兼容性）。

    // Set achievement for a user (called by PluginStore) // 更新特定用户的最新成就字符串
    function setAchievement(address user, string memory achievement) public { // PluginStore 合约可调用
        latestAchievement[user] = achievement;
    }

    // Get achievement for a user // 获取特定用户解锁的最新成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}