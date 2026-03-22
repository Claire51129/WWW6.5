// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 武器商店插件
// 和 AchievementsPlugin 结构完全一样，只是存储的内容不同（武器而非成就）
// 主合约不用改一行代码，注册一下就能多一个功能
contract WeaponStorePlugin {

    // 玩家地址 => 当前装备的武器名称
    mapping(address => string) public equippedWeapon;

    // 装备武器 - 给某个玩家设置当前武器
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    // 获取武器 - 查询某个玩家当前装备的武器
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}
