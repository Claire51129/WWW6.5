// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {

    mapping(address => string) public goodweapon;

    function setWeapon(string memory _weapon) public {
       goodweapon[msg.sender] = _weapon;
    }

    function getWeapon(address _player) public view returns (string memory) {
    return goodweapon[_player];
    }
}
