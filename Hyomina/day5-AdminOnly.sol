// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    address public owner;  // 合约所有者
    uint256 public treasureAmount;  // 宝藏总量
    
    // 映射:记录每个地址的提取额度
    mapping(address => uint256) public withdrawalAllowance;
    // 映射:记录地址是否已提取
    mapping(address => bool) public hasWithdrawn;
    
    // 构造函数:部署时设置owner
    constructor() {
        owner = msg.sender;
    }
    
    // 修饰符:只允许owner调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // 只有owner能添加宝藏
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }
    
    // 只有owner能批准提取额度
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        withdrawalAllowance[recipient] = amount;
    }
    
    // 任何人都可以提取(如果有额度)
    function withdrawTreasure(uint256 amount) public {
        require(amount <= withdrawalAllowance[msg.sender], "Insufficient allowance");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        
        hasWithdrawn[msg.sender] = true;
        withdrawalAllowance[msg.sender] -= amount;
    }
    
    // 只有owner能重置提取状态
    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }
    
    // 只有owner能转移所有权
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    // 只有owner能查看宝藏详情
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }
}