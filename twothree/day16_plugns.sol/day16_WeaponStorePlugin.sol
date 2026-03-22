// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {
    // 存储每个玩家装备的武器
    mapping(address => string) public equippedWeapon;
    
    // 装备武器
    function setWeapon(address user, string memory weapon) public { //定义setAchievement公共函数，接收用户地址和成就字符串作为参数
        equippedWeapon[user] = weapon;//将user地址对应的latestAchievement设置为传入的achievement值
    }
    
    // 获取武器
    function getWeapon(address user) public view returns (string memory) { //声明getAchievement为公共的只读函数，接受用户地址作为参数，返回一个字符串类型的值
        return equippedWeapon[user]; //函数内通过用户地址从latestAchievement映射中获取并返回该用户对应的最新成就
    }
}
