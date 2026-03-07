// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {
    address public bankManager;  
    address[] members;  
    mapping(address => bool) public registeredMembers;  
    mapping(address => uint256) balance;  
    
    constructor() {
        bankManager = msg.sender;
    }
    
    modifier onlyBankManager() {
        require(msg.sender == bankManager, "Not the bank manager");
        _;
    }
    
    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Not a registered member");
        _;
    }
    
    // 添加成员(只有管理员)
    function addMembers(address _member) public onlyBankManager {
        require(!registeredMembers[_member], "Already registered");
        registeredMembers[_member] = true;
        members.push(_member);
    }
    
    function getMembers() public view returns (address[] memory) {
        return members;
    }
    
    function deposit(uint256 _amount) public onlyRegisteredMember {
        balance[msg.sender] += _amount;
    }
    
    function depositAmountEther() public payable onlyRegisteredMember {
        balance[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 _amount) public onlyRegisteredMember {
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        balance[msg.sender] -= _amount;
    }
}