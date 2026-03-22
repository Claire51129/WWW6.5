//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AchievementsPlugin{
    //关联玩家最新成就和玩家地址
    mapping(address => string) public latestAchievement;

    function setAchievement(
        address user, //手动传递玩家地址
        string memory achievement  //成就名称
    ) public{
        latestAchievement[user] = achievement; //更新映射
    }

    function getAcheievement(address user)public view returns(string memory){
        return latestAchievement[user];
    }

}

//0x5C7078010eA1046720D08Daef080e1F75bB13682