// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 Ownable 合约
import "./day11_Ownable.sol";

contract VaultMaster is Ownable {

    // 存款事件
    event DepositSuccessful(address indexed account, uint256 value);

    // 提款事件
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    // 查询合约当前余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 允许任何人存入 ETH
    function deposit() public payable {

        // ETH为正
        require(msg.value > 0, "Enter a valid amount");

        // 记录存款事件
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 只有 owner 才可以提款
    function withdraw(address _to, uint256 _amount) public onlyOwner {

        // 检查余额是否足够
        require(_amount <= getBalance(), "Insufficient balance");

        // 向指定地址发送 ETH
        (bool success, ) = payable(_to).call{value: _amount}("");

        // 检查转账是否成功
        require(success, "Transfer Failed");

        // 记录提款事件
        emit WithdrawSuccessful(_to, _amount);
    }

}