// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// 所有权管理基础合约：实现所有权转移，供其他合约继承
contract Ownable {
    // 合约所有者地址（私有，仅内部可访问）
    address private owner;

    // 事件：所有权转移时触发，记录新旧所有者
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // 构造函数：部署时设部署者为初始所有者
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // 修饰器：仅合约所有者可调用被修饰函数
    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 获取所有者地址（view函数，仅读取状态）
    function ownerAddress() public view returns (address) {
        return owner;
    }

    // 转移所有权（仅所有者可调用）
    function transferOwnership(address _newOwner) public onlyOwner {
       // 校验：新地址不能为零地址
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner; // 暂存原所有者地址
        owner = _newOwner; // 更新所有者
        emit OwnershipTransferred(previous, _newOwner); // 触发所有权转移事件
    }
}