// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract AchievementsPlugin {
	mapping (address =>string) public latestAchievement;
	function setAchievement(address user, string memory Achievement) public {
		latestAchievement[user] = Achievement;
	}
	function getAchievement(address user) public view returns (string memory) {
		return (latestAchievement[user]);
	}
}