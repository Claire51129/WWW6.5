// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title WeaponStorePlugin
 * @dev Stores and retrieves a user's equipped weapon. Meant to be called via PluginStore.
 */
contract WeaponStorePlugin {
    mapping(address => string) public equippedWeapon;

    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    function getWeapon(address user) public view returns(string memory){
        return equippedWeapon[user];
    }/*尽管由于映射声明存在公共获取器，但显式编写此函数有助于：
        - 语义清晰
        - 面向未来（例如，我们可能以后想格式化名称或获取元数据）*/
}