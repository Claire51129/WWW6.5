//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    //State variables
    address public owner;
    uint256 public treasureAmount;
    mapping(address => uint256) public withdrawwalAllowance;
    mapping(address => bool) public hasWithdrawn;
    //add a cool down time
    uint256 public cooldownTime;
    mapping(address => uint256) public lastWithdrawalTime;
    //add maximum withdrawal limit
    mapping(address => uint256) public withdrawalLimit;
    //events when treasure is added, withdrawn or ownership changes
    event TreasureAdded(address indexed owner, uint256 amount, uint256 newTotal);
    event TreasureWithdrawn(address indexed user, uint256 amount, uint256 remainingTotal);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor sets the contract creator as the owner
    constructor() {
        owner = msg.sender;
    }

    //Modifier for owner-only functions
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Access denied: Only the owner can perform this action"
        );
        _;
    }

    //Only the owner can add treasure
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
        emit TreasureAdded(msg.sender, amount, treasureAmount);
    }

    //Only the owner can approve withdrawals
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available.");
        withdrawwalAllowance[recipient] = amount;
    }

    //Anyone can attempt to withdraw, but only those with allowance will succeed
    function withdrawTreasure(uint256 amount) public {
        if (msg.sender == owner) {
            require(
                amount <= treasureAmount,
                "Not enough treasury available for this action."
            );
            treasureAmount -= amount;
            emit TreasureWithdrawn(msg.sender, amount, treasureAmount);
            return;
        }

        uint256 allowance = withdrawwalAllowance[msg.sender];
        //check if user has an allowance and hasn't withdrawn yet
        require(allowance > 0, "You don't have any treasure allowance.");
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure.");
        require(allowance >= amount, "Cannot withdraw more than you are allowed.");
        require(block.timestamp >= lastWithdrawalTime[msg.sender] + cooldownTime, "You have achieved the limitation withdrawl times. Wait longer.");
        require(amount <= withdrawalLimit[msg.sender], "Amount exceeds your withdrawal limit.");
        //Mark as withdrawn and reduce treasure
        hasWithdrawn[msg.sender] = true;
        treasureAmount -= amount;  //was treasureAmount -= allowance, thought this would be better
        withdrawwalAllowance[msg.sender] = 0;
        lastWithdrawalTime[msg.sender] = block.timestamp;

        emit TreasureWithdrawn(msg.sender, amount, treasureAmount);
    }

    //Only the owner can reset someone's withdrawal status
    function resetWithdrawlStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }

    // Only the owner can transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }

    function setCooldownTime(uint256 newCooldownTime) public onlyOwner {
        cooldownTime = newCooldownTime;
    }

    //add a view function tell user if they can withdraw
    function canWithdrawn() public view returns (bool) {
        if(msg.sender == owner) {
            return treasureAmount > 0;
        }

        uint256 allowance = withdrawwalAllowance[msg.sender];
        if(allowance == 0) {
            return false;
        }
        if(hasWithdrawn[msg.sender]){
            return false;
        }
        if(block.timestamp < lastWithdrawalTime[msg.sender] + cooldownTime){
            return false;
        }

        return true;
    }

    //add max withdrawal limit
    function setWithdrawalLimit(address user, uint256 limit) public onlyOwner {
        withdrawalLimit[user] = limit;
    }
}
