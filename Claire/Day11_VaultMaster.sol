// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./Day11_Ownable.sol";

contract VaultMaster is Ownable{
//引入Ownable
//is Ownable = 继承，自动获得owner和onlyOwner

    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed reciepient, uint256 value);
    //存钱、取钱成功就触发事件
    function getBalance()public view returns(uint256){
        return address(this).balance;
        //查询余额
    }

    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
        //所有人都可以存钱，必须真的给钱，发事件通知谁存了多少钱
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
       //取钱：只有主可以，检查钱够不、转给_to，发事件 
    }

}