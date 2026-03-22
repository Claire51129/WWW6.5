// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/*@openzeppelin 部分是简写，用于引用来自 npm 风格包系统的信息包。
- `@openzeppelin/...` = "从 OpenZeppelin 库包中获取这个"
- `contracts/access/Ownable.sol` = 该包内的实际文件夹和文件路径*/
contract VaultMaster is Ownable{

    event DepositSuccessful(address indexed account, uint256 amount);
    event WithdrawSuccessful(address indexed resipient, uint256 amount);

    constructor() Ownable(msg.sender){}

    function getBalance()public view returns(uint256){
        return address(this).balance;
    }

    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    //从Ownable中继承了onlyOwner
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }
}