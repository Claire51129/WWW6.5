// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Day 16 - 武器商店插件
 * 
 * 另一个独立的插件合约，展示多插件架构
 */
contract WeaponStorePlugin {
    
    // 武器信息
    struct Weapon {
        string name;        // 武器名称
        uint256 equippedAt; // 装备时间
        uint256 damage;     // 伤害值
        bool equipped;      // 是否已装备
    }
    
    // 每个玩家的装备
    mapping(address => Weapon) public equippedWeapon;
    mapping(address => string[]) public weaponCollection;  // 拥有的武器列表
    
    // 武器属性库（简单示例）
    mapping(string => uint256) public weaponDamage;
    
    // 事件
    event WeaponEquipped(address indexed user, string weaponName, uint256 damage);
    event WeaponUnequipped(address indexed user);
    
    constructor() {
        // 初始化一些武器属性
        weaponDamage["Wooden Sword"] = 10;
        weaponDamage["Iron Sword"] = 25;
        weaponDamage["Excalibur"] = 100;
        weaponDamage["Dragon Slayer"] = 150;
    }
    
    /**
     * 装备武器
     */
    function setWeapon(address user, string memory weaponName) external {
        require(bytes(weaponName).length > 0, "Empty weapon name");
        
        uint256 damage = weaponDamage[weaponName];
        if (damage == 0) damage = 10; // 默认伤害
        
        equippedWeapon[user] = Weapon({
            name: weaponName,
            equippedAt: block.timestamp,
            damage: damage,
            equipped: true
        });
        
        // 添加到收藏（如果不存在）
        bool alreadyOwned = false;
        for (uint i = 0; i < weaponCollection[user].length; i++) {
            if (keccak256(bytes(weaponCollection[user][i])) == keccak256(bytes(weaponName))) {
                alreadyOwned = true;
                break;
            }
        }
        if (!alreadyOwned) {
            weaponCollection[user].push(weaponName);
        }
        
        emit WeaponEquipped(user, weaponName, damage);
    }
    
    /**
     * 卸下武器
     */
    function unequipWeapon(address user) external {
        equippedWeapon[user].equipped = false;
        emit WeaponUnequipped(user);
    }
    
    /**
     * 获取当前装备
     */
    function getWeapon(address user) external view returns (string memory) {
        return equippedWeapon[user].name;
    }
    
    /**
     * 获取完整武器信息
     */
    function getWeaponInfo(address user) 
        external 
        view 
        returns (string memory, uint256, uint256, bool) 
    {
        Weapon memory w = equippedWeapon[user];
        return (w.name, w.equippedAt, w.damage, w.equipped);
    }
    
    /**
     * 获取武器收藏
     */
    function getWeaponCollection(address user) external view returns (string[] memory) {
        return weaponCollection[user];
    }
    
    /**
     * 添加新武器到图鉴（权限控制简化版）
     */
    function addWeaponType(string memory name, uint256 damage) external {
        weaponDamage[name] = damage;
    }
}