// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MathLib {
    function calculateBonus(uint256 _amount, uint256 _percentage) internal pure returns (uint256) {
        return (_amount * _percentage) / 100;
    }

    function exists(address[] storage _array, address _target) internal view returns (bool) {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == _target) return true;
        }
        return false;
    }
}

contract BonusVault {
    using MathLib for uint256;
    using MathLib for address[];

    mapping(address => uint256) public balances;
    address[] public members;

    function deposit() public payable {
        if (!members.exists(msg.sender)) {
            members.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    function getBalanceWithBonus(address _user, uint256 _bonusPercent) public view returns (uint256) {
        uint256 currentBalance = balances[_user];
        uint256 bonus = currentBalance.calculateBonus(_bonusPercent);
        return currentBalance + bonus;
    }
}
