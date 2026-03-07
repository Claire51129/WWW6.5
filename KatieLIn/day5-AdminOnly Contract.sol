// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract AdminOnly{
    address public  owner;
    uint256 public  treasureAmount;

    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => bool) public hasWithdrawn;
    mapping(address =>uint256) public lastWithdrawalTime;
    uint256 public cooldownTime = 5 minutes;
    uint256 public maxWithdrawalPerUser = 1000;

    event TreasureAdded (uint256 amount);
    event Withdrawal (address indexed user, uint256 amount);
    event OwnershipTransferred (address indexed oldOwner, address indexed newOwner);

    constructor(){
        owner=msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender== owner,"Access denied; only the owner can perform this action.");
        _;
    }

    function addTreasure(uint256 amount) public onlyOwner{
        treasureAmount += amount;
        emit TreasureAdded(amount);
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner{
        require(amount <= treasureAmount,"Not enough treasure available.");
        withdrawalAllowance[recipient]=amount;
    }

    function withdrawAllowance(uint256 amount) public {

        if(msg.sender == owner){
            require(amount <= treasureAmount,"Not enough treasury available for this action.");
            treasureAmount-= amount;
            emit Withdrawal(msg.sender, amount);

            return ;
        }
        uint256 allowance = withdrawalAllowance[msg.sender];

        require(allowance>0,"you don't have any treasure allowance");
        require(!hasWithdrawn[msg.sender],"you have already withdrawn your treasure");
        require(allowance<=treasureAmount,"Not enough treasure in the chest");
        require(allowance>= amount,"Cannot withdraw more than you are allowed");
        require(
            block.timestamp >= lastWithdrawalTime[msg.sender]+cooldownTime,
            "Cooldown time not finished."
        );
        hasWithdrawn[msg.sender]=true;
        lastWithdrawalTime[msg.sender]=block.timestamp;
        treasureAmount-=amount;
        withdrawalAllowance[msg.sender]-= amount;
    }
    function checkMystatus() public view returns(
        uint256 allowance,
        bool withdrawn,
        uint256 nextAvailableTime
    ){
        allowance = withdrawalAllowance[msg.sender];
        withdrawn = hasWithdrawn[msg.sender];
        nextAvailableTime =lastWithdrawalTime[msg.sender]+cooldownTime;
    }

    function resetWithdrawalStatus(address user) public onlyOwner{
        hasWithdrawn[user]=false;
    }

    function transferOwnership(address newOwner) public  onlyOwner{
        require(newOwner !=address(0),"Invalid address");
        address oldOwner = owner;
        owner =newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function getTreasureDetails() public view onlyOwner returns (uint256){
        return treasureAmount;
    }

}