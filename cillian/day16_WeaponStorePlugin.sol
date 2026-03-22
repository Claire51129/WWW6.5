// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 武器商店插件 (WeaponStorePlugin)
 * @dev 供 PluginStore 调用的外部合约，用于存储玩家当前的武器装备信息。
 */
contract WeaponStorePlugin {

    // 映射：存储每个玩家地址当前装备的武器名称
    // 例如：0xABC... => "屠龙宝刀"
    mapping(address => string) public equippedWeapon;

    /**
     * @dev 为指定用户设置装备的武器
     * @notice 对应 PluginStore 中的 runPlugin 调用
     * @param user 玩家的钱包地址
     * @param weapon 武器名称字符串（如 "黄金斧头"）
     */
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    /**
     * @dev 获取指定用户当前装备的武器
     * @notice 对应 PluginStore 中的 runPluginView 调用
     * @param user 玩家的钱包地址
     * @return 返回该玩家当前装备的武器名称
     */
    function getWeapon(address user) public view returns(string memory) {
        return equippedWeapon[user];
    }
    
}