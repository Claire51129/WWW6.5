// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
contract AdminOnly {
	// Register events to hook frontend
	event TreasureAdded(uint256 amount);
	event TreasureWithdrawn(address indexed user, uint256 amount);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	address public owner;
	uint256 public treasureAmount;
	mapping (address => uint256) public withdrawAmount;
	// Allow withdrawal only once
	mapping (address => bool) public hasWithdrawn;
	// Cooltime between 2 withdrawals
	mapping (address => uint256) public withdrawTime;
	// Cooldown interval
	uint256 public constant COOLDOWN = 300;

	constructor() {
		owner = msg.sender;
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Access denied: this is owner-only operation");
		// placeholder
		_;
	}
	function addTreasure(uint _amount) public onlyOwner {
		require(_amount > 0, "Increment should be positive");
		treasureAmount += _amount;
		// fire event
		emit TreasureAdded(_amount);
	}
	function approveWithdraw(address _recipient, uint256 _amount) public onlyOwner {
		require(_amount <= treasureAmount, "Not enough treasure");
		withdrawAmount[_recipient] = _amount;
	}
	function withdrawTreasure(uint256 _amount) public {
		// Owner has no restrictions on withdrawal
		if (msg.sender == owner)
		{
			require(_amount <= treasureAmount, "Not enough treasure");
			treasureAmount -= _amount;
			emit TreasureWithdrawn(msg.sender, _amount);
			return ;
		}
		// Users have restrictions on withdrawal
		uint256 allowance = withdrawAmount[msg.sender];
		require(allowance > 0, "Not allowed to withdraw");
		require(!hasWithdrawn[msg.sender], "Already withdrawn");
		// Can happen even if enough treasure when approved
		require(_amount <= treasureAmount, "Not enough treasure");
		require(_amount <= allowance, "Not enough withdraw allowance");
		// No cooldown for first withdrawal
		if (withdrawTime[msg.sender] != 0)
			require(block.timestamp >= withdrawTime[msg.sender] + COOLDOWN, "Retry after cooldown time");
		treasureAmount -= _amount;
		hasWithdrawn[msg.sender] = true;
		withdrawAmount[msg.sender] = 0;
		withdrawTime[msg.sender] = block.timestamp;
		emit TreasureWithdrawn(msg.sender, _amount);
	}
	// Reset cooldown and permission, but not amount (by another function)
	function resetWithdrawStatus(address recipient) public onlyOwner {
		hasWithdrawn[recipient] = false;
		withdrawTime[recipient] = 0;
	}
	function transferOwnership(address recipient) public onlyOwner {
		require(recipient != address(0), "Address not exist");
		address oldOwner = owner;
		owner = recipient;
		// fire event
		emit OwnershipTransferred(oldOwner, owner);
	}
	// Owner getter
	function getTreasureDetail() public view onlyOwner returns (uint256) {
		return (treasureAmount);
	}
	// User getter
	function getUserStatus() public view returns (bool, bool) {
		bool isApproved = withdrawAmount[msg.sender] > 0;
		return (isApproved, hasWithdrawn[msg.sender]);
	}
}