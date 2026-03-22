// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//武器插件：存储每个玩家的当前装备的武器

//使用标准的设置器模式，以便 PluginStore 可以将其调用委托出去
contract WeaponStorePlugin {
    // user => weapon name
    mapping(address => string) public equippedWeapon;
    
    //更新用户的当前装备武器
    // Set the user's current weapon (called via PluginStore)
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }
    //获取用户的当前装备武器
    // Get the user's current weapon
    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}

//****如何融入插件系统****
//如果玩家想要装备一把新武器，运行runPlugin(..)函数
//pluginStore.runPlugin("weapon","setWeapon(address,string)",msg.sender,"Golden Axe");
//如果我们想知道他们使用什么武器，运行runPluginView(..)函数
//pluginStore.runPluginView("weapon","getWeapon(address)",userAddress);