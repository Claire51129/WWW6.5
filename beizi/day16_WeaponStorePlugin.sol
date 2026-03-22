// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin{
    mapping(address => string) public equippedWeapon;//跟踪每个玩家装备了哪种武器

//允许我们更新玩家当前装备的武器
    function setWeapon(address user, string memory weapon) public {
    equippedWeapon[user] = weapon;
}

//查看特定地址所装备的武器
function getWeapon(address user) public view returns (string memory) {
    return equippedWeapon[user];
}
}
