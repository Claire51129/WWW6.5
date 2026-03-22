//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// AchievementsPlugin - 成就插件合约
// 这是一个简单的插件合约，用于记录用户的最新成就
// 可以被 PluginStore 合约调用，作为插件系统的一部分
contract AchievementsPlugin{

    // 存储每个用户的最新成就
    // key: 用户地址
    // value: 成就名称（字符串）
    mapping(address => string) public latestAchievement;

    // 设置用户的成就
    // user: 用户地址
    // achievement: 成就名称
    // 注意: 此函数可以被 PluginStore 通过 call 调用
    function setAchievement(address user, string memory achievement) public{
        latestAchievement[user] = achievement;
    }

    // 获取用户的最新成就
    // user: 用户地址
    // 返回: 该用户的最新成就名称
    function getAcheievement(address user)public view returns(string memory){
        return latestAchievement[user];
    }

}

//0x5C7078010eA1046720D08Daef080e1F75bB13682
