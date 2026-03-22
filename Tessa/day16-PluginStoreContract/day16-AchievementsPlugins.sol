// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AchievmentsPlugin{

    mapping(address => string) public latestAchievement;   //每个人的最新成就

    // 给用户设置成就
    function setAchievement(address user, string memory achievement) public{
        latestAchievement[user] = achievement;
    }

    // 获取查询成就
    function getAchievement(address user)public view returns(string memory){
        return latestAchievement[user];
    }

}

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99
