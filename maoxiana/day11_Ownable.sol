// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// 一个**可重复使用的合约**，它：
// - 跟踪当前所有者
// - 限制对敏感函数的访问
// - 允许转移所有权
// - 发出事件，使所有权更改被公开记录

//跟踪谁是所有者，并使用 onlyOwner 修饰符保护敏感函数
//可重复使用的访问控制合约，适用于需要所有权管理的各种场景，如权限控制、资源管理等。
contract Ownable {
    //private表示owner变量只能在Ownable合约内部访问，外部合约无法直接访问该变量。这是一种封装机制，确保只有合约内部的函数可以修改owner的值，从而增强了安全性。
    address private owner;

    //OwnershipTransferred在所有权发生转移时触发，记录了之前的所有者地址和新的所有者地址。这有助于跟踪所有权变更历史，并提供透明度。
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    //为什么前面privitee的owner变量需要一个公共的访问函数？因为private修饰符限制了owner变量只能在Ownable合约内部访问，外部无法直接访问该变量。为了让外部用户能够查询当前的所有者地址，我们需要提供一个公共的访问函数（如ownerAddress()），这样用户就可以通过调用这个函数来获取当前的所有者地址，而不需要直接访问private变量。这种设计既保护了owner变量的安全性，又提供了必要的功能接口。
    //如果owner是public的，外部也不可以改动，为啥不用public？而且下面的这个访问函数也是公开性的。不过访问函数可以调整访问设置，但如果本合约中应该没差？
    function ownerAddress() public view returns (address) {
        return owner;
    }

    //只有所有者可以调用这个函数来转移所有权，确保了只有当前所有者才能更改所有权，从而增强了安全性。
    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}