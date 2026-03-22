// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract GoldVault {
	mapping(address => uint256) public goldBalance;
	uint256 private _status;
	uint256 private constant _NOT_ENTERED = 1;
	uint256 private constant _ENTERED = 2;
	constructor() {
		_status = _NOT_ENTERED;
	}
	modifier nonReentrant() {
		require(_status != _ENTERED, "Reentrant call blocked");
		_status = _ENTERED;
		_;
		_status = _NOT_ENTERED;
	}
	function deposit() external payable {
		require(msg.value > 0, "Deposit must be positive");
		goldBalance[msg.sender] += msg.value;
	}
	// Reentrance
	function vulnerableWithdraw() external {
		uint256 amount = goldBalance[msg.sender];
		require(amount > 0, "Not enough balance");
		(bool sent, ) = payable(msg.sender).call{value:amount}("");
		require(sent, "Transfer failed");
		goldBalance[msg.sender] = 0;
	}
	// Should avoid Reentrance
	function safeWithdraw() external {
		uint256 amount = goldBalance[msg.sender];
		require(amount > 0, "Not enough balance");
		goldBalance[msg.sender] = 0;
		(bool sent, ) = payable(msg.sender).call{value:amount}("");
		require(sent, "Transfer failed");
	}
}