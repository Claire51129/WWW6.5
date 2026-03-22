// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {
    // 存储每个地址当前装备的武器
    mapping(address => string) public equippedWeapon;
    
    // 装备武器（修改状态）
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }
    
    // 获取武器（只读）
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}
