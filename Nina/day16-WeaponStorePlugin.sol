/** 武器商店插件 — 以模块化方式追踪装备的武器
在许多游戏中，每个玩家可以携带或装备武器——比如剑、弓、激光枪或某些自定义物品。这个插件处理的就是这些。
就像 `AchievementsPlugin` 一样，这个合约设计为通过  **主`PluginStore`合约**  来使用。它存储每个玩家的  **当前装备的武器** ，并允许核心合约  **设置**  和  **获取**  该武器。
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title WeaponStorePlugin
 * @dev Stores and retrieves a user's equipped weapon. Meant to be called via PluginStore.
 */
contract WeaponStorePlugin {
    // user => weapon name
    mapping(address => string) public equippedWeapon;

    // Set the user's current weapon (called via PluginStore)
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // Get the user's current weapon
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}