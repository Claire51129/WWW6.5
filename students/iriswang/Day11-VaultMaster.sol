// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day11-Ownable.sol";

contract VaultMaster is Ownable {
    // 暂停功能
    bool public paused;
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    // 原有事件
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit() public payable whenNotPaused {
        require(msg.value > 0, "Must send ETH");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner whenNotPaused {
        require(_amount <= address(this).balance, "Insufficient balance");
        payable(_to).transfer(_amount);
        emit WithdrawSuccessful(_to, _amount);
    }

    // 暂停/恢复函数
    function pause() public onlyOwner {
        require(!paused, "Already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        require(paused, "Already unpaused");
        paused = false;
        emit Unpaused(msg.sender);
    }
}
