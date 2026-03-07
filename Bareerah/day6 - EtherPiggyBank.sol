// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank{
    address public manager;
    address [] members;
    mapping (address => bool) isRegistered;
    mapping (address => uint256) balance;

    constructor(){
        manager = msg.sender;
        members.push(msg.sender);
    }

    modifier onlyRegisteredMember{
        require(isRegistered[msg.sender], "Not registed!");
        _;
    }

    modifier onlyBankManager{
        require(msg.sender == manager, "Not bank manager!");
        _;
    }

    event depositEther(address member, uint256 amount);
    event withdrawEther(address member, uint256 amount);

    function getMembers() public view returns (address[] memory){
        return members;
    }
    
    function addMembers(address _member) public onlyBankManager{
        require(!isRegistered[_member], "Already registered!");
        require(_member != msg.sender,"Manager is already a member!");
        require(_member != address(0), "Invalid address");
        members.push(_member);
        isRegistered[_member] = true;
    }

    function deposit(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        balance[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance!");
        balance[msg.sender] -= _amount;
    }

    
    function depositAmountEther() public payable onlyRegisteredMember{
        require(msg.value > 0, "Invalid amount");
        balance[msg.sender] += msg.value;
        emit depositEther(msg.sender, msg.value);
    }

// Exercises
    function withdrawAmountEther() public payable onlyRegisteredMember{
        require(msg.value > 0, "Invalid amount");
        require(balance[msg.sender] >= msg.value, "Insufficient balance!");
        balance[msg.sender] -= msg.value;
        emit withdrawEther(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256){
        return balance[msg.sender];
    }

    function getTotalBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function removeMember(address _member) public onlyBankManager{
        require(isRegistered[_member], "User not registered");
        isRegistered[_member] = false;        
        balance[_member] = 0;
    }
}