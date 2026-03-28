// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract SimpleLending {
	mapping(address => uint256) public depositBalance;
	mapping(address => uint256) public borrowBalance;
	mapping(address => uint256) public collateralBalance;
	// interest rate 5% one year
	uint256 public interestRateBasis = 500;
	// collateral rate 75%
	uint256 public collateralRateBasis = 7500;
	mapping(address => uint256) public lastInterestAccrualTimestamp;
	event Deposit(address indexed user, uint256 amount);
	event Withdraw(address indexed user, uint256 amount);
	event Borrow(address indexed user, uint256 amount);
	event Repay(address indexed user, uint256 amount);
	event CollateralDeposited(address indexed user, uint256 amount);
	event CollateralWithdrawn(address indexed user, uint256 amount);
	// Deposit money to contract
	function deposit() external payable {
		require(msg.value > 0, "Invlid deposit");
		depositBalance[msg.sender] += msg.value;
		emit Deposit(msg.sender, msg.value);
	}
	// Withdraw money from contract
	function withdraw(uint256 amount) external {
		require(amount > 0, "Invalid withdraw");
		require(amount <= depositBalance[msg.sender], "Insufficient balance");
		depositBalance[msg.sender] -= amount;
		(bool success, ) = payable(msg.sender).call{value:amount}("");
		require(success, "Fail to transfer");
		emit Withdraw(msg.sender, amount);
	}
	// Deposit collateral to contract
	function depositCollateral() external payable {
		require(msg.value > 0, "Invalid deposit");
		collateralBalance[msg.sender] += msg.value;
		emit CollateralDeposited(msg.sender, msg.value);
	}
	// Calculate interest and debt altogether
	function calculateInterestAccrual(address user) public view returns (uint256) {
		if (borrowBalance[user] == 0) {
			return 0;
		}
		uint256 timePassed = block.timestamp - lastInterestAccrualTimestamp[user];
		uint256 interest = (borrowBalance[user] * interestRateBasis * timePassed) / (10000 * 365 days);
		return borrowBalance[user] + interest;
	}
	// Withdraw collateral when sufficient for current debt
	function withdrawCollateral(uint256 amount) external {
		require(amount > 0, "Invalid withdraw");
		require(collateralBalance[msg.sender] >= amount, "Insufficient collateral deposit");
		uint256 borrowedAmount = calculateInterestAccrual(msg.sender);
		uint256 requireCollateral = (borrowedAmount * 10000) / collateralRateBasis;
		require(collateralBalance[msg.sender] - amount >= requireCollateral, "Withdrawl would break collateral ratio");
		collateralBalance[msg.sender] -= amount;
		(bool success, ) = payable(msg.sender).call{value:amount}("");
		require(success, "Fail to transfer");
		emit CollateralWithdrawn(msg.sender, amount);
	}
	// Borrow from contract according to collateral
	// Update debt before new debt and update timestamp
	function borrow(uint256 amount) external {
		require(amount > 0, "Invalid borrow");
		require(address(this).balance > amount, "Not enough liquidity");
		uint256 maxBorrow = collateralBalance[msg.sender] * collateralRateBasis / 10000;
		uint256 currentDebt = calculateInterestAccrual(msg.sender);
		require(currentDebt + amount <= maxBorrow, "Exceed borrow limit");
		borrowBalance[msg.sender] = currentDebt + amount;
		lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
		(bool success, ) = payable(msg.sender).call{value:amount}("");
		require(success, "Fail to transfer");
		emit Borrow(msg.sender, amount);
	}
	// Repay current debt
	// Pay extra money back to sender
	function repay() external payable {
		require(msg.value > 0, "Invalid repay");
		uint256 currentDebt = calculateInterestAccrual(msg.sender);
		require(currentDebt > 0, "No debt");
		uint256 amountToPay = msg.value;
		if (msg.value > currentDebt){
			amountToPay = currentDebt;
			(bool success, ) = payable(msg.sender).call{value:msg.value - currentDebt}("");
			require(success, "Fail to transfer");
		}
		borrowBalance[msg.sender] = currentDebt - amountToPay;
		lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
		emit Repay(msg.sender, amountToPay);
	}
	function getMaxBorrow(address user) external view returns (uint256) {
		return (collateralBalance[user] * collateralRateBasis / 10000);
	}
	function getLiquidity() external view returns (uint256) {
		return address(this).balance;
	}
}