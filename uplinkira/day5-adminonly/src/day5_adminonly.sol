// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AdminOnly {
    address public owner;
    uint256 public treasureAmount;
    mapping(address => uint256) public withdrawalAllowance;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: only owner");
        _;
    }

    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] = amount;
    }

    function withdrawTreasure(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        if (msg.sender == owner) {
            require(amount <= treasureAmount, "Not enough treasure");
            treasureAmount -= amount;
            return;
        }

        uint256 allowance = withdrawalAllowance[msg.sender];
        require(amount <= allowance, "Amount exceeds allowance");
        require(amount <= treasureAmount, "Not enough treasure");

        withdrawalAllowance[msg.sender] = allowance - amount;
        treasureAmount -= amount;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }

    function resetAllowance(address recipient) public onlyOwner {
        withdrawalAllowance[recipient] = 0;
    }
}
