// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
    // 合约所有者地址
    address private owner;
    // 事件，所有权变更
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // 初始所有者，触发所有权变更事件
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    // 自定义修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    // 可公开查看所有者的函数
    function ownerAddress() public view returns (address) {
        return owner;
    }
    // 所有权变更函数
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
    }
}
