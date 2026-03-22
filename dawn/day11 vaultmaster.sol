// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day11 ownable.sol";

contract VaultMaster is Ownable {
    // 新的事件
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");
        emit DepositSuccessful(msg.sender, msg.value);
    }
    
    // 使用继承的onlyOwner修饰符
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        payable(_to).transfer(_amount);
        emit WithdrawSuccessful(_to, _amount);
    }
}