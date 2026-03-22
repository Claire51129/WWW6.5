// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 武器装备插件
 * @dev 负责管理玩家在游戏中的武器持有情况
 */
contract WeaponStorePlugin {
    // 数据存储：玩家地址 => 装备的武器名称（如 "Excalibur", "Wooden Sword"）
    mapping(address => string) public equippedWeapon;
    
    /**
     * @notice 装备武器
     * @dev 注意：这里的参数顺序是 (string, address)
     * @param weapon 武器名称
     * @param user 玩家地址
     */
    function setWeapon(string memory weapon, address user) public {
        // 将武器名称绑定到对应的玩家地址上
        equippedWeapon[user] = weapon;
    }
    
    /**
     * @notice 获取玩家当前武器
     * @param user 玩家地址
     * @return 返回武器名称字符串
     */
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}