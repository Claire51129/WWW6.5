// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
    // 存储每个玩家的最新成就
    mapping(address => string) public latestAchievement;
    
    // 设置成就
    function setAchievement(address user, string memory achievement) public { //它是一个公共函数，可接收用户地址和成就信息作为参数
        latestAchievement[user] = achievement; //将用户对应的最新成就设置为传入的成就信息
    }
    
    // 获取成就
    function getAchievement(address user) public view returns (string memory) {  //声明getAchievement公共只读函数，接收用户地址参数，返回字符串类型数据。
        return latestAchievement[user]; //根据传入的用户地址，从latestAchievement映射中获取并返回该用户对应的最新成就
    }
}