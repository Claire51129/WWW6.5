// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 成就系统插件 (AchievementsPlugin)
 * @dev 这是一个可以被 PluginStore 调用的示例插件合约。
 */
contract AchievementsPlugin {

    // 映射：存储每个玩家地址对应的最新成就描述
    // 例如：0x123... => "初出茅庐"
    mapping(address => string) public latestAchievement;

    /**
     * @dev 设置玩家的成就
     * @notice 对应 PluginStore 中的 runPlugin 调用
     * @param user 玩家的钱包地址
     * @param achievement 成就内容字符串
     */
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    /**
     * @dev 获取玩家的成就
     * @notice 对应 PluginStore 中的 runPluginView 调用
     * @param user 玩家的钱包地址
     * @return 返回该玩家最新获得的成就字符串
     */
    function getAcheievement(address user) public view returns(string memory) {
        return latestAchievement[user];
    }
    
}