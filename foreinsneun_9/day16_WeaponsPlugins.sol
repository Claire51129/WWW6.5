// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract WeaponsPlugin {
    mapping(address => string) public equippedWeapon;
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    function getWeapon(address user) public view returns(string memory) {
        return equippedWeapon[user];
    }
}