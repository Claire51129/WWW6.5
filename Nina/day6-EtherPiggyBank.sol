//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EtherPiggyBank{

    //there should be a bank manager who has the certain permissions
    //there should be an array for all members registered and a mapping whther they are registered or not
    //a mapping with there balances
    address public bankManager;
    address[] members; //从 Solidity 0.5.0 开始，编译器强制要求：所有函数必须显式声明可见性（public, external, internal, 或 private）。所有状态变量如果不写默认为 internal。
    mapping(address => bool) public registeredMembers;
    mapping(address => uint256) balance;

    //合约部署后，部署者称为bankManager和members中的第一位成员
    constructor(){
        bankManager = msg.sender;
        members.push(msg.sender);
        registeredMembers[msg.sender] = true;
    }

    modifier onlyBankManager(){
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }

    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }
  
    //add members to the bank
    function addMembers(address _member)public onlyBankManager{
        require(_member != address(0), "Invalid address");
        require(!registeredMembers[_member], "Member already registered");
        members.push(_member);
        registeredMembers[_member] = true;
    }

    //get members of the bank
    function getMembers() public view returns(address[] memory){
        return members;
    }
    //deposit amount 
    function depositAmount(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        balance[msg.sender] = balance[msg.sender]+_amount;
   }
    
    //deposit in Ether
    function depositAmountEther() public payable onlyRegisteredMember{  
        require(msg.value > 0, "Invalid amount");
        balance[msg.sender] = balance[msg.sender]+msg.value;
    }
    //msg 是全局变量，msg.value 是它的属性
        //在 Solidity 中，有一些变量是始终存在于全局命名空间中的，它们主要用来提供关于“区块链网络”或“当前交易”的信息。
        //msg (Message): 这是一个包含当前调用信息的对象。
        //msg.value: 本次交易发送的以太币数量（以 Wei 为单位）.
        //msg.sender: 当前调用者的地址。
        //msg.data: 完整的调用数据（calldata）。
        //msg.sig: 函数选择器（前 4 个字节）。
    //payble是一个修饰符（Modifier），它告诉以太坊虚拟机（EVM）：“这个函数（或地址）被允许接收以太币。”
        //对于函数：如果你在一个函数上标记了 payable，那么当有人在调用这个函数时顺便转了 ETH，msg.value 就会记录这个金额。
        //如果不写 payable：如果你尝试向一个普通的函数发送 ETH，交易会直接失败（Revert）。
    
    //withdraw amount
    function withdrawAmount(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        balance[msg.sender] = balance[msg.sender]-_amount;
    }

    //check balance of any registered member
    function getBalance(address _member) public view returns (uint256){
        require(_member != address(0), "Invalid address");
        return balance[_member];
    } 
}

