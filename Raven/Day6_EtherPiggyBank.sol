// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
contract EtherPiggyBank {
	address public bankManager;
	address [] members;
	mapping(address => bool) public registeredMembers;
	mapping(address => uint) balance;

	// Add bank manager to members and register
	constructor() {
		bankManager = msg.sender;
		members.push(msg.sender);
		registeredMembers[msg.sender] = true;
	}
	// Only manager has access
	modifier managerOnly() {
		require(msg.sender == bankManager, "Access denied: this is manager only operation");
		_;
	}
	// Only registered members have access
	modifier registeredMembersOnly() {
		require(registeredMembers[msg.sender] == true, "Access denied: this is registered members only operation");
		_;
	}
	// Manager adds and registers members
	function addMembers(address _member) public managerOnly {
		require(_member != address(0), "Invalid member address");
		require(_member != bankManager, "Bank manager already registered");
		require(!registeredMembers[_member], "Already registered");
		registeredMembers[_member] = true;
		members.push(_member);
	}
	// Get member array
	function getMembers() public view returns (address [] memory) {
		return (members);
	}
	// Deposit ether to bank (real money)
	function deposit() public registeredMembersOnly payable{
		require(msg.value > 0, "Invalid deposit amount");
		balance[msg.sender] += msg.value;
	}
	// Withdraw from account (number)
	function withdraw(uint256 _amount) public registeredMembersOnly {
		require(_amount > 0, "Invalid withdraw amount");
		require(_amount <= balance[msg.sender], "Not enough money in account");
		balance[msg.sender] -= _amount;
	}
	// Get balance of each member
	function getBalance(address _member) public view returns (uint256) {
		require(_member != address(0), "Invalid member address");
		return (balance[_member]);
	}
}