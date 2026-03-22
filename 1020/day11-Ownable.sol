// SPDX-License-Identiier:MIT
pragma solidity ^0.8.20;

//新知识
//一个合约（"母合约"）定义了一堆逻辑——函数、变量、修饰符等。
//另一个合约（"子合约"）继承了这一切——可以按原样使用，或者修改其中的部分以满足自己的需求。

contract Ownable{
    address private owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner);
    constructor(){
        owner=msg.sender;
        emit OwnershipTransferred(address(0),msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Only owener can perform this action");
        _;
    }

    function ownerAddress() public view returns(address){
        return owner;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner!=address(0),"Invalid address");
        address previous=owner;
        owner=_newOwner;
        emit OwnershipTransferred(previous,_newOwner);
    }
}