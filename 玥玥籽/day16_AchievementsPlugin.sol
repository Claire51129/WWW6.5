// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {

    mapping(address => string[]) private _achievements;

    event AchievementUnlocked(address indexed user, string achievement, uint256 totalCount);

    function setAchievement(address _user, string memory _achievement) public {
        _achievements[_user].push(_achievement);
        emit AchievementUnlocked(_user, _achievement, _achievements[_user].length);
    }

    function getAchievement(address _user) public view returns (string memory) {
        string[] storage list = _achievements[_user];
        if (list.length == 0) return "";
        return list[list.length - 1];
    }

    function getAchievementCount(address _user) external view returns (uint256) {
        return _achievements[_user].length;
    }

    function getAllAchievements(address _user) external view returns (string[] memory) {
        return _achievements[_user];
    }
}
