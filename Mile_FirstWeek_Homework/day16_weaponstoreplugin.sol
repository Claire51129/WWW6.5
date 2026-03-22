// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title day16_WeaponStorePlugin
 * @dev 插件示例 2: 武器商店
 * 
 * 此合约独立管理玩家的装备数据。
 * 展示了如何在不修改主合约的情况下，无限扩展新功能。
 */
contract day16_WeaponStorePlugin {
    
    // 映射：玩家地址 -> 当前装备的武器
    mapping(address => string) public equippedWeapon;
    
    /**
     * @dev 装备武器
     * @param user 玩家地址
     * @param weapon 武器名称 (e.g., "Excalibur")
     */
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }
    
    /**
     * @dev 获取当前装备
     * @return 武器名称字符串
     */
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}