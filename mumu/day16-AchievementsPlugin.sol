// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
  @notice 成就插件合约
 */

 contract AchievementsPlugin{
    // player=>achievemenet string
    mapping (address => string) public latesAchievement;

    function setAchievement(address _player, string memory _achievement) public{
        latesAchievement[_player] = _achievement;
    }

    function getAchievement(address _player) public view returns(string memory){
        return latesAchievement[_player];
    }
 }

 /**
 两个函数的签名分别为：
 setAchievement(address,string)
 getAchievement(address)
 
  */