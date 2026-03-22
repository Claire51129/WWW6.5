// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title day16_AchievementsPlugin
 * @dev 插件示例 1: 成就系统
 * 
 * 此合约独立管理玩家的成就数据。
 * 它不知道 PluginStore 的存在，只是一个普通的合约，
 * 可以被任何拥有其地址的合约通过 call 调用。
 */
contract day16_AchievementsPlugin {
    
    // 映射：玩家地址 -> 最新成就字符串
    mapping(address => string) public latestAchievement;
    
    /**
     * @dev 设置玩家成就
     * @param user 玩家地址
     * @param achievement 成就描述 (e.g., "First Blood")
     * 
     * ⚠️ 注意: 函数必须是 public 或 external 才能被外部调用
     */
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }
    
    /**
     * @dev 获取玩家成就
     * @return 成就描述字符串
     */
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}