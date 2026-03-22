
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
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function ownerAddress() public view returns (address) {
        return owner;
    }

    //转移所有权
    //和前事件参数对应，将当前的所有者地址存储到一个局部变量 previous 中。这样做的目的是为了在后续发出 OwnershipTransferred 事件时，能够提供前任所有者的信息，确保事件记录的完整性和准确性。这种临时存储避免了在事件发出时直接使用已更新的 owner 值，从而正确地反映转移前的状态。
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previous = owner; //
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
    }
}
