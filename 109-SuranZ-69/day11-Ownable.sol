// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//第一部分，母合约，可供其他子合约继承并重复使用
contract Ownable {
    //将部署合约的人定义为所有者
    address private owner;

    //当发生所有权转移的时候，会有previouOwner和newOwner两个变量需要被记录监听；indexed表示可索引
    event OwnershipTransferred (address indexed previousOwner, address indexed newOwner);

    //合约部署时，就将发送一次日志：将当前部署者作为初始所有者，previousOwner为0
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    //设置调用权限
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    //检查当前的所有者是谁（前面定义所有者时是private的）
    function ownerAddress() public view returns (address) {
        return owner;
    }

    //允许将所有权转让给其他人，并通过OwnershipTrasferred事件来记录
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address.");
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
    }
}