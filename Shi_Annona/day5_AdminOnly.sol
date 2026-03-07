//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AdminOnly{

    //we need owner, treasure, user, the allowance, the amount of withdraw
    address public owner;
    uint256 private treasureAmount;// only owner can see and change the treasureAmount,so it is private
    
    //I used to think I need have an address array before I use mapping. But I don't have to
    mapping(address => uint256) withdrawAmount;
    mapping(address => bool) hasWithdraw;
    
    //don't forgot the parentheses after key word "constractor", cause it is a function. 
    constructor(){
        owner = msg.sender; //the administrator is who deploys the contract
    }

    //the tool of check the authority
    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied, only administrator can perform this action");
        _; //attention: it is an underline! not a middle line!
    }

    // set the amount of the treasure, remember functions always need a Visibility and state mutability modifiers
    // punlic private  view internal external pure
    function SetTreasureAmount(uint _amount) public onlyOwner(){
        treasureAmount = _amount;
    }

    //authorization
    function approvalWithdraw(address _recipient,uint256 _amount) public onlyOwner(){
        require(_amount < treasureAmount , "too much");
        withdrawAmount[_recipient] = _amount;
    }

    //withdraw treasure
    function withdrawTreasure(uint _amount) public{
        
        //chcke if the action comes from owner
        if(msg.sender == owner){
            require(_amount <= treasureAmount, "Not enough treasure for this action");
            treasureAmount -= _amount;

            return;//end the function 
        }

        uint256 allowAmount = withdrawAmount[msg.sender];
        require(allowAmount > 0,"you don'y have any treasure");
        require(_amount <= allowAmount, "Cannot withdraw more than you are allowed");
        require(!hasWithdraw[msg.sender], "You have already withdrawn your treasure");

        hasWithdraw[msg.sender] = true;
        treasureAmount -= _amount;
        withdrawAmount[msg.sender] = 0;

    }

    //set the state of hasWithdraw only owner
    function resetWithdrawState(address _user) public onlyOwner(){
        hasWithdraw[_user] = false;
    }

    //close the authority of withdraw
    function closeWithdrawAuth(address _user) public onlyOwner(){
        hasWithdraw[_user] = true;
    }

    //change owner
    function changeOwber(address _NewOwner) public onlyOwner(){
        require(_NewOwner != address(0), "Invalid address");//address[0] means the addres is null
        owner = _NewOwner;
    }

    //see the amount of owner, don't forget view
    function checkTreasure() public view onlyOwner() returns(uint256){
        return treasureAmount;

    }
}