// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AdminOnly
{
    address public owner;
    constructor()
    {
        owner=msg.sender;
    }

    modifier onlyOwner()//修饰符
    {
        require(msg.sender==owner,"Access denied:Only the owner can perform this action");
        _;//占位符
    }

    uint256 public treasureAmount;
    function add_treasure(uint256 amount)public onlyOwner
    {
        treasureAmount+=amount;
    }

    mapping(address=>uint256)public withdrawal_allowance;
    function approve_withdrawal(address recipient,uint256 amount)public onlyOwner
    {
        require(amount<=treasureAmount,"Not enough treasure available");
        withdrawal_allowance[recipient]=amount;
    }

    mapping(address=>bool)public hasWithdrawn;
    function withdraw_treasure(uint256 amount)public
    {
        if(msg.sender==owner)
        {
            require(amount<=treasureAmount,"Not enough treasury available for this action.");
            treasureAmount-=amount;
        }

        uint256 allowance=withdrawal_allowance[msg.sender];
        require(allowance>0,"You don't have any treasure allowance.");
        require(!hasWithdrawn[msg.sender],"You have already withdrawn your treasure.");
        require(allowance<=treasureAmount,"Not enough treasure in the chest.");

        hasWithdrawn[msg.sender]=true;
        treasureAmount-=allowance;
        withdrawal_allowance[msg.sender]=0;
    }

    function reset_withdrawalStatus(address user)public onlyOwner
    {
        hasWithdrawn[user]=false;
    }

    function transferOwnership(address newOwner)public onlyOwner
    {
        require(newOwner!=address(0),"Invalid address");
        owner=newOwner;
    }

    function get_treasureDetails()public view onlyOwner returns(uint256)
    {
        return treasureAmount;
    }
}
