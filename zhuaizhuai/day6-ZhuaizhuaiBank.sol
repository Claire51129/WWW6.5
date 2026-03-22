// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZhuaizhuaiBank {
    // State variables
    address public owner;
    uint256 public  treasureAmount;
    mapping (address => uint256) public withdrawalAllowance;
    mapping (address => bool) public hasWithdrawn;
    
    // constructor sets the contract creator as the owner
    constructor() {
        owner = msg.sender;
    }

    //modifier for owner-olny function
    modifier onlyOwner(){
        require(msg.sender == owner,"access denied: olny the owenr can perform this action");
        _;
    }


    // Olny the owner can add treasure
    function addTresure() public payable onlyOwner {
        treasureAmount += msg.value;
    }

    //Olny the owner can approve withdrawals
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] =amount;
    }

    //Anyone can attempt to withdraw, but only those with allowence will succed
    function withdrawTreasure(uint256 amount) public {
        if(msg.sender == owner){
            require(amount <= treasureAmount,"Not enought treasure available for this action");
            treasureAmount-= amount;
            return;
        }
        uint256 allowence = withdrawalAllowance[msg.sender];

        //check if user has an allowence and hasn't withdrawn yet
        require(allowence > 0,"you don't have any treasure allowence");
        require(!hasWithdrawn[msg.sender],"you have already hasWithdrawn your treasure");
        require(allowence <= treasureAmount,"Not enough treasure in the chest");
        require(allowence >= amount,"cannot withdrawn more than you are allowed"); //condition on check if user is withdrawing more than allowed

        //Mark as withdrawn and reduce tresure
        hasWithdrawn[msg.sender] = true;
        treasureAmount -= allowence;
        withdrawalAllowance[msg.sender] = 0;
        
    }

    //olny the owner can rest someone's withdrawal status

    function resetWithdrawalStates(address user) public onlyOwner{
        hasWithdrawn[user] = false;

    }

    //olny the owner can transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"Invalid address");
        owner = newOwner;
    }

    function getTreasureDetails() public  view onlyOwner returns (uint256){
        return  treasureAmount;
    }
}
