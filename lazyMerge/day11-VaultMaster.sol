
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11-Ownable.sol";
// 也可以引入第三方包
// import "@openzeppelin/contracts/access/Ownable.sol";

// VaultMaster 继承自 Ownable。
contract VaultMaster is Ownable {
    // 入金成功
    event DepositSuccessful(address indexed account, uint256 value);
    // 出金成功
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 允许所有人
    function deposit() public payable {
        require(msg.value > 0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 这里加了 onlyOWner 的限制
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");

        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");

        emit WithdrawSuccessful(_to, _amount);
    }
}

