// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./day11-Ownable.sol";    // 引用别的程序

//存钱取钱的银行（保险箱银行）
contract VaultMaster is Ownable{    //VaultMaster 继承Ownable（VaultMaster自动拥有管理员系统）


    event DepositSuccessful(address indexed account, uint256 value);    //事件：有人存钱
    event WithdrawSuccessful(address indexed reciepient, uint256 value);    //事件：有人取钱


    function getBalance()public view returns(uint256){    //功能：查看保险箱余额
        return address(this).balance;    // 返回（当前合约）的钱
    }

    function deposit()public payable{    //存钱；payable指这个函数可以接收ETH
        require ( msg.value > 0, "Enter a valid amount");    //存钱数额需大于0，否则“”
        emit DepositSuccessful(msg.sender, msg.value);    //广播：某人存了多少钱
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {    //取钱(仅管理员)
        require(_amount <= getBalance(), "Insufficient balance");    //检查余额够不够
        (bool success , ) = payable(_to).call{value: _amount}("");    //给某个地址转ETH
        require(success, "Transfer Failed");    //检查是否成功，否则“”
        emit WithdrawSuccessful(_to, _amount);    //广播：成功取钱
    }
}



//区块链保险箱流程： 用户→存钱(deposit)→VaultMaster合约 保存ETH →管理员withdrwa()→转账给指定地址