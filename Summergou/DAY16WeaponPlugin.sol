//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract WeaponPlugin{
    //user => weapon name
    mapping(address => string) equippedWeapon; 

    //set current weapon
    function setWeapon(address _user, string memory _weapon) public {
        equippedWeapon[_user] = _weapon;
    }
    
    //get current weapon 

    function getWeapin(address _user) public view returns(string memory){
        return equippedWeapon[_user];
    }
}
