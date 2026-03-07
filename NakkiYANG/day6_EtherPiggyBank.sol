// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {
    address public bankManager;  // 银行管理员
    address[] members;  // 成员列表
    mapping(address => bool) public registeredMembers;  // 注册状态
    mapping(address => uint256) balance;  // 余额记录
    
    constructor() {
        bankManager = msg.sender;
    }
    
    // 修饰符:只有管理员
    modifier onlyBankManager() {
        require(msg.sender == bankManager, "Not the bank manager");
        _;
    }
    
    // 修饰符:只有注册成员
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
    
    // 获取所有成员
    function getMembers() public view returns (address[] memory) {
        return members;
    }
    
    // 记录存款(不真实转ETH,仅记账)
    function deposit(uint256 _amount) public onlyRegisteredMember {
        balance[msg.sender] += _amount;
    }
    
    // 真实存入ETH
    function depositAmountEther() public payable onlyRegisteredMember {
        balance[msg.sender] += msg.value;
    }
    
    // 提取(仅记账,不真实转ETH)
    function withdraw(uint256 _amount) public onlyRegisteredMember {
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        balance[msg.sender] -= _amount;
    }
}