// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./day11_Ownable.sol";

//一个让用户存入 ETH 的金库，但只有所有者可以提取资金。
//VaultMaster 将继承 Ownable 的所有函数、变量和修饰符
contract VaultMaster is Ownable{

    //当有人向合约发送 ETH 时触发，记录了发送者地址和发送的金额。这有助于跟踪存款活动，并提供透明度。
    event DepositSuccessful(address indexed account, uint256 value);
    //当所有者从合约提取 ETH 时触发。记录了接收者地址和提取的金额。这有助于跟踪提款活动，并提供透明度。
    event WithdrawSuccessful(address indexed recipient, uint256 value);
    
    //返回合约当前持有的 ETH 数量。
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }

    //允许任何人向合约发送 ETH。
    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    //允许从合约中提取 ETH——但只有所有者有权限执行此操作。
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }

}