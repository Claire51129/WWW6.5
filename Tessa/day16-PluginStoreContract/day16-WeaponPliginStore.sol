// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract WeaponStorePlugin{

    mapping(address => string) public equippedWeapon;    // 存储玩家装备的武器

    // 设置武器：给玩家装备武器
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // 获取武器：查询武器
    function getWeapon(address user) public view returns(string memory){
        return equippedWeapon[user];
    }
}