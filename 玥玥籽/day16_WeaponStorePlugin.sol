// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {

    struct WeaponRecord {
        string name;
        uint8 tier;
        uint32 equippedAt;
    }

    mapping(address => WeaponRecord) public equippedWeapon;

    mapping(address => WeaponRecord[5]) private _history;
    mapping(address => uint8) private _historyIndex;

    event WeaponEquipped(address indexed user, string weaponName, uint8 tier);

    function setWeapon(address _user, string memory _weaponName) public {
        _equipWeapon(_user, _weaponName, 1);
    }

    function equipWeapon(address _user, string memory _weaponName, uint8 _tier) external {
        require(_tier >= 1 && _tier <= 5, "Tier must be 1-5");
        require(
            _tier >= equippedWeapon[_user].tier,
            "Cannot equip lower tier weapon"
        );
        _equipWeapon(_user, _weaponName, _tier);
    }

    function _equipWeapon(address _user, string memory _weaponName, uint8 _tier) internal {
        uint8 idx = _historyIndex[_user];
        _history[_user][idx] = WeaponRecord(_weaponName, _tier, uint32(block.timestamp));
        _historyIndex[_user] = (idx + 1) % 5;

        equippedWeapon[_user] = WeaponRecord(_weaponName, _tier, uint32(block.timestamp));
        emit WeaponEquipped(_user, _weaponName, _tier);
    }

    function getWeapon(address _user) public view returns (string memory) {
        return equippedWeapon[_user].name;
    }

    function getWeaponTier(address _user) external view returns (uint8) {
        return equippedWeapon[_user].tier;
    }

    function getHistory(address _user) external view returns (WeaponRecord[5] memory) {
        return _history[_user];
    }
}
