// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {

    mapping(address => string[]) public goodachievement;

    function setAchievement(string memory _achievement) public {
        goodachievement[msg.sender].push(_achievement);
    }

    function getAchievement(address _player) public view returns (string[] memory) {
        return goodachievement[_player];
    }
}
