// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {

    mapping(address => string) public latestAchievement;

    //设置成就函数
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    //获取成就
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }

//这里不用写import，因为在pluginstore里有registerplugin，可以添加插件名字和地址，直接使用这份1合同
}