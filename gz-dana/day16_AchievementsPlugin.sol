// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Day 16 - 成就系统插件
 * 
 * 这是一个独立的插件合约，存储玩家的成就数据
 * 通过 call 从 PluginStore 调用时，修改的是本合约的存储
 */
contract AchievementsPlugin {
    
    // 成就记录
    struct Achievement {
        string name;        // 成就名称
        uint256 unlockedAt; // 解锁时间
        bool unlocked;      // 是否已解锁
    }
    
    // 每个玩家的成就列表
    mapping(address => mapping(string => Achievement)) public achievements;
    mapping(address => string[]) public userAchievementList;  // 用于遍历
    mapping(address => uint256) public achievementCount;
    
    // 事件
    event AchievementUnlocked(address indexed user, string achievementName, uint256 timestamp);
    event AchievementSet(address indexed user, string achievementName);
    
    /**
     * 设置/解锁成就
     * 
     * 注意：当通过 PluginStore.call() 调用时，
     * msg.sender = PluginStore 地址，不是原始调用者！
     * 
     * 所以如果插件需要权限控制，应该额外传入 user 参数
     */
    function setAchievement(address user, string memory achievementName) external {
        require(bytes(achievementName).length > 0, "Empty achievement name");
        
        // 如果是新成就，添加到列表
        if (!achievements[user][achievementName].unlocked) {
            userAchievementList[user].push(achievementName);
            achievementCount[user]++;
        }
        
        achievements[user][achievementName] = Achievement({
            name: achievementName,
            unlockedAt: block.timestamp,
            unlocked: true
        });
        
        emit AchievementSet(user, achievementName);
        emit AchievementUnlocked(user, achievementName, block.timestamp);
    }
    
    /**
     * 获取单个成就信息
     */
    function getAchievement(address user, string memory achievementName) 
        external 
        view 
        returns (string memory, uint256, bool) 
    {
        Achievement memory a = achievements[user][achievementName];
        return (a.name, a.unlockedAt, a.unlocked);
    }
    
    /**
     * 简化版 - 只返回成就名称（用于兼容性）
     */
    function getLatestAchievement(address user) external view returns (string memory) {
        uint256 count = achievementCount[user];
        if (count == 0) return "";
        
        string memory latestName = userAchievementList[user][count - 1];
        return latestName;
    }
    
    /**
     * 获取玩家所有成就名称
     */
    function getAllAchievements(address user) external view returns (string[] memory) {
        return userAchievementList[user];
    }
    
    /**
     * 获取成就数量
     */
    function getAchievementCount(address user) external view returns (uint256) {
        return achievementCount[user];
    }
    
    /**
     * 检查是否已解锁某个成就
     */
    function hasAchievement(address user, string memory achievementName) 
        external 
        view 
        returns (bool) 
    {
        return achievements[user][achievementName].unlocked;
    }
}