// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AdminOnly {
    address public owner;
    uint256 private treasureAmount;

    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => bool) public hasWithdraw;
    // 冷却时间计时器
    mapping(address => uint) public lastWithdrawTime;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    // 冷却检查 用户只能每隔5分钟提取一次
    modifier cooldown() {
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 300, "Must wait 5 minutes between withdrawals");
        _;
    }

    // 声明事件
    event Withdraw(address indexed user, uint amount, uint timestamp);

    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }

    function withdrawTreasure(uint256 amount) public cooldown {
        if (msg.sender == owner) {
            require(treasureAmount >= amount, "Not enough treasury available for this action.");
            treasureAmount -= amount;
            return;
        }

        uint256 allowance = withdrawalAllowance[msg.sender];
        require(allowance > 0, "You don't have any treasure allowance");
        require(!hasWithdraw[msg.sender], "You have already withdrawn your treasure");
        require(allowance >= amount, "Cannot withdraw more than you are allowed");
        require(treasureAmount >= amount, "Not enough treasure in the chest");

        hasWithdraw[msg.sender] = true;
        withdrawalAllowance[msg.sender] -= amount;
        treasureAmount -= amount;
        // 更新时间戳
        lastWithdrawTime[msg.sender] = block.timestamp;
        // 触发事件
        emit Withdraw(msg.sender, amount, lastWithdrawTime[msg.sender]);
    }

    function approveWithdrawal(address user, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[user] = amount;
    }

    function transferOwnerShip(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function resetWithdrawalStaus(address user) public onlyOwner {
        hasWithdraw[user] = false;
    }

    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }

    // 添加一个查询函数，让用户查看自己是否被批准、是否已提取
    function getApproved() public view returns (bool, bool) {
        return (withdrawalAllowance[msg.sender] > 0, hasWithdraw[msg.sender]);
    }

}
