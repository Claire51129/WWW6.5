// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract Ownable {
    address private owner;
//存主人地址，且只有合约内部可以直接访问
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//主人换了就发这个事件
    constructor() {//开始构造函数
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
//部署者成为主人
//发事件：从空地址(0)转给新主人
    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    function ownerAddress() public view returns (address) {
        return owner;
    }
//返回主人地址（因为owner是private）
    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
//换主
    }
}