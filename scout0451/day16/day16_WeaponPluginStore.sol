//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract WeaponStorePlugin{
    //关联玩家的武器名称和玩家地址
    mapping(address => string) public equippedWeapon;

    //它使插件逻辑与访问控制的处理方式保持解耦
    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    function getWeapon(address user) public view returns(string memory){
        return equippedWeapon[user];
    }
}
