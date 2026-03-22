// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Olny owner can perform this action");
        _;
    }

    function ownerAdress() public view returns (address){
        return owner;
    }
    function tranferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner !=address(0),"invalid adress");
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
    }

    
}
