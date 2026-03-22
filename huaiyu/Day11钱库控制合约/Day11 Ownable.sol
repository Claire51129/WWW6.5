// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
//private 所以只能在这个合约内部访问，其他合约无法直接访问它
contract Ownerble {
    address private owner;
// indexed 过滤
    event OwnershipTransferred(address indexed priviousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    //owner私有的
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    
    function ownerAddress() public view returns (address) {
        return owner;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        require (_newOwner !=address(0), "Invalid address");
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}
