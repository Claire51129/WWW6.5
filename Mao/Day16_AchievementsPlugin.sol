// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 成就系统插件
 * @dev 这是一个独立的逻辑合约，被 PluginStore 调用来管理玩家成就
 */
contract AchievementsPlugin {
    
    // 核心数据存储：玩家地址 => 获得的最新成就字符串
    // 注意：这个数据是存在这个“插件合约”自己的存储空间里的
    mapping(address => string) public latestAchievement;
    
    /**
     * @notice 设置成就 (由 PluginStore 的 runPlugin 调用)
     * @param user 玩家的地址
     * @param achievement 成就名称，例如 "森林探索者"
     */
    function setAchievement(address user, string memory achievement) public {
        // 逻辑：更新该玩家在本项目中的成就记录
        latestAchievement[user] = achievement;
    }
    
    /**
     * @notice 获取成就 (由 PluginStore 的 runPluginView 调用)
     * @param user 玩家的地址
     * @return 返回该玩家获得的最新成就内容
     */
    function getAchievement(address user) public view returns (string memory) {
        // 逻辑：从 mapping 中读取并返回
        return latestAchievement[user];
    }
}