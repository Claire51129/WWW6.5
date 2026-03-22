// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
    address public pluginStore;
    mapping(address => string) public latestAchievement;

  
    constructor(address _pluginStore) {
        pluginStore = _pluginStore;
    }


    modifier onlyPluginStore() {
        require(msg.sender == pluginStore, "Not authorized");
        _;
    }


    function setAchievement(address user, string memory achievement) public onlyPluginStore {
        latestAchievement[user] = achievement;
    }

    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}