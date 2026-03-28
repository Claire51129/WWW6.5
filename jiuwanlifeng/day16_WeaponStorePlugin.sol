//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {
    
    mapping(address => string) public equippedWeapon;

    function setWeapon(address player, string memory weaponName) public {
        equippedWeapon[player] = weaponName;
    }

    function getWeapon(address player) public view returns (string memory) {
        return equippedWeapon[player];
    }
    
    
}