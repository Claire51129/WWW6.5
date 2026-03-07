//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract SimpleIOU {
	address public owner;
	address [] public friends;
	mapping (address => bool) public registered;
	mapping (address => uint256) public balance;
	// debtor - creditor - amount
	mapping (address => mapping(address => uint256)) public debt;
	// Add owner to friends and register
	constructor() {
		owner = msg.sender;
		friends.push(owner);
		registered[owner] = true;
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Only owner has access to operate");
		_;
	}
	modifier onlyRegistered() {
		require(registered[msg.sender], "Only registered has access to operate");
		_;
	}
	function addFriend(address _friend) public onlyOwner {
		require(_friend != address(0), "Invalid friend address");
		require(!registered[_friend], "Friend already registered");
		registered[_friend] = true;
		friends.push(_friend);
	}
	function deposit() public payable onlyRegistered {
		require(msg.value > 0, "Invalid deposit amount");
		balance[msg.sender] += msg.value;
	}
	function withdraw(uint256 _amount) public onlyRegistered {
		require(balance[msg.sender] > 0, "Not enough money in account");
		require(_amount <= balance[msg.sender], "Insufficient balance");
		balance[msg.sender] -= _amount;
		// empty = byte return value; "" = calldata
		// call() requires payable type
		(bool success, ) = payable (msg.sender).call{value:_amount}("");
		require(success, "Withdrawal failed");
	}
	// Creditor records debt
	function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
		require(_debtor != address(0), "Invalid debtor address");
		require(registered[_debtor], "Debtor is not registered");
		require(_amount > 0, "Invalid debt amount");
		debt[_debtor][msg.sender] += _amount;
	}
	// Pay debts by internal account balance
	function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
		require(_creditor != address(0), "Invalid creditor address");
		require(registered[_creditor], "creditor is not registered");
		require(_amount > 0, "Invalid payment amount");
		require(debt[msg.sender][_creditor] >= _amount, "Payment more than debt");
		require(balance[msg.sender] >= _amount, "Insufficent balance");
		balance[msg.sender] -= _amount;
		balance[_creditor] += _amount;
		debt[msg.sender][_creditor] -= _amount;
	}
	// // Transfer alternative Ether
	// // transfer() is deprecated
	// function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
	// 	require(_to != address(0), "Invalid address");
	// 	require(registered[_to], "Recipient is not registered");
	// 	require(_amount > 0, "Invalid payment amount");
	// 	require(balance[msg.sender] >= _amount, "Insufficent balance");
	// 	balance[msg.sender] -= _amount;
	// 	_to.transfer(_amount);
	// }
	// Transfer alternative Ether using call()
	// Handle gas freely and check success manually
	function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
		require(_to != address(0), "Invalid address");
		require(registered[_to], "Recipient is not registered");
		require(_amount > 0, "Invalid payment amount");
		require(balance[msg.sender] >= _amount, "Insufficent balance");
		balance[msg.sender] -= _amount;
		(bool success, ) = _to.call{value:_amount}("");
		require(success, "Transfer failed");
	}
	// Friends check their own account balance
	function getBalance() public view onlyRegistered returns (uint256) {
		return (balance[msg.sender]);
	}
}