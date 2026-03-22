// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin 
{
    // 跟踪每个玩家装备了哪种武器
    mapping(address => string) public equippedWeapon;

    // Set the user's current weapon (called via PluginStore)更新
    // PluginStore调用，生成user，不使用msg.sender
    function setWeapon(address user, string memory weapon) public 
    {
        equippedWeapon[user] = weapon;
    }

    // 显式编写此函数有助于：1语义清晰 2面向未来（例如，我们可能以后想格式化名称或获取元数据）
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}
