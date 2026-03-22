// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialJarV2 {
    address public owner;
    mapping(address => bool) public registeredMembers;
    mapping(address => uint256) public balances;

    event MemberAdded(address indexed newMember);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error NotOwner();
    error NotMember();
    error InsufficientBalance(uint256 requested, uint256 available);

    constructor() {
        owner = msg.sender;
        registeredMembers[msg.sender] = true;
        emit MemberAdded(msg.sender); 
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(); 
        _;
    }

    modifier onlyMember() {
        if (!registeredMembers[msg.sender]) revert NotMember();
        _;
    }

    function addMember(address _member) public onlyOwner {
        require(_member != address(0), "Invalid address");
        registeredMembers[_member] = true;
    
        emit MemberAdded(_member);
    }

    function deposit() public payable onlyMember {
        require(msg.value > 0, "Amount must be > 0");
        balances[msg.sender] += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public onlyMember {
        uint256 currentBalance = balances[msg.sender];
        
        if (currentBalance < _amount) {
            revert InsufficientBalance(_amount, currentBalance);
        }

        balances[msg.sender] -= _amount;
    
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, _amount);
    }
}
