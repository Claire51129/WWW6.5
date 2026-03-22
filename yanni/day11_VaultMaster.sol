// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11_Ownable.sol";

//两个事件
//DepositSuccessful用于记录成功的存款，包括存款者地址和金额；
//WithdrawSuccessful用于记录成功的取款，包括接收者地址和金额。
contract VaultMaster is Ownable {
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    function getBalance() public view returns (uint256) {
        return address(this).balance; //this为内置关键字
    }

    function deposit() public payable {
        require(msg.value > 0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance.");

        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");

        emit WithdrawSuccessful(_to, _amount);
    }
}
