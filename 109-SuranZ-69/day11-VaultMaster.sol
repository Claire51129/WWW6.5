// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11-Ownable.sol";

contract VaultMaster is Ownable { //代表了VaultMaster合约继承自Ownable，自动拥有其所有函数、变量和修饰符
    //定义两个事件：成功存钱、成功取钱
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    //返回当前合约持有的所有ETH数量
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //允许任何人向合约发送ETH的函数
    function deposit() public payable {
        require(msg.value > 0, "Enter a valid amount.");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    //允许所有者从合约中提取ETH的函数
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance.");

        (bool success, ) = payable (_to).call{value: _amount}("");
        require(success, "Transfer Failed.");

        emit WithdrawSuccessful(_to, _amount);
    }
}