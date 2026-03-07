// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EtherPiggyBank{
    address public bankManager;
    address[] members;
    mapping (address => bool) public registeredMembers;
    mapping (address => uint256) public balance;
    mapping (address =>uint256) public lastDepositTime;
    uint256 public withdrawCooldown = 1 minutes;
    event Deposit(address indexed user,uint256 amount);
    event Withdraw(address indexed user,uint256 amount);
    //indexed :

    constructor(){
        bankManager = msg.sender;
        registeredMembers[msg.sender]=true;
        members.push(msg.sender);
    }

    modifier onlyBankManager(){
        require(msg.sender == bankManager,"Only bank manager can perform this action");
        _;
    }

    modifier onlyRegisteredMember(){
        require(registeredMembers[msg.sender],"Member not registered");
        _;
    }

    function addMembers(address _member)public onlyBankManager{
        require(_member != address(0),"Invalid address");
        require(_member !=msg.sender, "Bank Manager is already a member");
        require(!registeredMembers[_member],"Member already registered");

        registeredMembers[_member]=true;
        members.push(_member);
    }

    function getMembers()public view returns(address[]memory){
        return members;
    }

    function depositAmountEther() public payable onlyRegisteredMember{
        require(msg.value > 0,"Invalid amount");
        balance[msg.sender] += msg.value;
        lastDepositTime[msg.sender] = block.timestamp;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawAmount(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0,"Invalid amount");
        require(balance[msg.sender]>=_amount,"Insufficient balance");
        require(block.timestamp >= lastDepositTime[msg.sender]+withdrawCooldown,
        "Withdrawal cooldown active");
        balance[msg.sender]=balance[msg.sender]-_amount;
        (bool success,) = payable (msg.sender).call{value:_amount}("");
        require(success,"Transfer failed");
        emit Withdraw(msg.sender, _amount); 
    }

    function getBalance(address _member) public view returns (uint256){
        require(_member !=address(0),"Invalid address");
        return balance[_member];
    } 
}

