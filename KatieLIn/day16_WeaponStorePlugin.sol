// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {
    address public pluginStore;
    mapping(address => string) public equippedWeapon;


    constructor(address _pluginStore) {
        pluginStore = _pluginStore;
    }

 
    modifier onlyPluginStore() {
        require(msg.sender == pluginStore, "Not authorized");
        _;
    }

    function setWeapon(address user, string memory weapon) public onlyPluginStore {
        equippedWeapon[user] = weapon;
    }

    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}