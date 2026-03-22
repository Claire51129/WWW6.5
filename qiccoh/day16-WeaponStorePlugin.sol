// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title WeaponStorePlugin
 * @dev Stores and retrieves a user's equipped weapon. Meant to be called via PluginStore.
 */
contract WeaponStorePlugin {
    // 玩家装备的武器
    mapping(address => string) public equippedWeapon;

    // 更新玩家当前装备的武器
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // 获取用户的当前装备武器
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}