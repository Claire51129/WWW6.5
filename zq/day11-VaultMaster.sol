// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11-ownable.sol";
contract VaultMaster is Ownable {
    // 发送eth、提取eth时触发事件
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);
    // 合约当前持有的 ETH 数量
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    // 允许任何人向合约发送eth，触发发送eth事件
    function deposit() public payable   {
        require(msg.value > 0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }
    // 提取eth，发送，触发提取事件
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
    }
}