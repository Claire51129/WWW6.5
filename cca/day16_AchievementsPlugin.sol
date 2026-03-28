// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract AchievementsPlugin {
    mapping(address => string) public latestAchievement;
    //被标记为 public ，这意味着 Solidity 会自动免费创建一个 getter 函数
    //但是自定义getter更灵活 可添加格式、返回多个成就

    function setAchievement(address user,string memory achievement)public {
        latestAchievement[user] = achievement;
    }//有意保持开放，以便插件可以在任何地方重用
    //PluginStore代替玩家调用 所以不用msg.sender

    function getAchievement(address user)public view returns(string memory){
        return latestAchievement[user];
    }
}