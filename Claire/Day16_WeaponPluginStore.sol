//SPDX-License-Identifier: MIT
// 代码开源协议
pragma solidity ^0.8.0;
// 指定Solidity编译器版本

contract WeaponStorePlugin{
// 定义一个合约，叫"武器商店插件"
// 这个合约可以被注册到PluginStore里，作为插件使用

    mapping(address => string) public equippedWeapon;
    // mapping：映射，像字典一样
    // address => string：通过玩家地址，找到他装备的武器名字
    // public：自动生成getter函数，外部可以直接调用equippedWeapon(地址)来查看
    // 作用：记录每个玩家装备了什么武器

    function setWeapon(address user, string memory weapon) public {
    // 函数：给玩家装备武器
    // address user：要装备武器的玩家地址
    // string memory weapon：武器名字（存在内存中）
    // public：公开函数，任何人都可以调用
        
        equippedWeapon[user] = weapon;
        // 把武器名字存到mapping里
        // 键是玩家地址，值是武器名字
    }

    function getWeapon(address user) public view returns(string memory){
    // 函数：查看玩家装备的武器
    // view：只读函数，不修改链上数据
    // returns(string memory)：返回武器名字（字符串）
        
        return equippedWeapon[user];
        // 从mapping中取出这个玩家的武器并返回
    }
}