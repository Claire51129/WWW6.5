// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly{
    address public owner;
    uint256 public treasureAmount;
    bool public isPaused;

    mapping (address => uint256) public withdrawalAllowance;
    mapping (address => bool) public hasWithdraw;    
    mapping (address => bool) public isRegistered;
    mapping (address => bool) public isAdmin;

    modifier onlyAdmin(){
        require(isAdmin[msg.sender], "Only admins can do this.");
        _;
    }

    modifier onlyRegisteredUser(){
        require(isRegistered[msg.sender], "User is not registered.");
        _;
    }

    modifier notPaused(){
        require(!isPaused, "Contract is currently paused.");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied: Only the owner can perform this action.");
        _;
    }

    event TreasureAdded(uint256 amount, uint256 newTotal);
    event UserRegistered(address indexed user);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractPaused(bool status);
    event WithdrawalExecuted(address indexed user, uint256 amount);

    constructor(){
        owner = msg.sender;
        isAdmin[msg.sender] = true;
    }

    function addTreasure(uint256 amount) public onlyAdmin notPaused{
        treasureAmount += amount;
        emit TreasureAdded(amount, treasureAmount);
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner{
        require(amount <= treasureAmount, "Not enough treasure available!");
        withdrawalAllowance[recipient] = amount;
    }

    function withdrawTreasure() public onlyRegisteredUser notPaused{
        uint256 allowance = withdrawalAllowance[msg.sender];
        require(allowance > 0, "You need to approve enough allowance!");
        require(!hasWithdraw[msg.sender], "You have already withdrawn your treasure!");
        require(allowance <= treasureAmount, "Not have enough allowance!");
        hasWithdraw[msg.sender] = true;
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;
        
        emit WithdrawalExecuted(msg.sender, allowance);
    }

    function resetWithdrawlStatus(address user) public onlyOwner{
        hasWithdraw[user] = false;
    }

    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Invalid address!");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getTreasureDetails() public view onlyAdmin returns(uint256){
        return treasureAmount;
    }

    function setAdmin(address admin, bool status) public onlyOwner{
        require(admin != address(0), "Invalid address");
        isAdmin[admin] = status;
    }

    function registerUser(address user) public onlyOwner{
        require(user != address(0), "Invalid address");
        require(!isRegistered[user], "Already registered.");
        isRegistered[user] = true;
        emit UserRegistered(user);
    }

    function setPaused(bool _status) public onlyOwner{
        isPaused = _status;
        emit ContractPaused(_status);
    }
}