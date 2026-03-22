//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// WeaponStorePlugin - 武器商店插件合约
// 这是一个简单的插件合约，用于记录用户装备的武器
// 可以被 PluginStore 合约调用，作为插件系统的一部分
contract WeaponStorePlugin{

    // 存储每个用户当前装备的武器
    // key: 用户地址
    // value: 武器名称（字符串，如 "Golden Axe", "Silver Sword" 等）
    mapping(address => string) public equippedWeapon;

    // 设置用户的装备武器
    // user: 用户地址
    // weapon: 武器名称
    // 注意: 此函数可以被 PluginStore 通过 call 调用
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // 获取用户当前装备的武器
    // user: 用户地址
    // 返回: 该用户装备的武器名称
    function getWeapon(address user) public view returns(string memory){
        return equippedWeapon[user];
    }
}
