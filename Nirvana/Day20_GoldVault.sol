// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract GoldVault {
	mapping(address => uint256) public goldBalance; // 映射记录每个用户在金库中存了多少ETH

	//Reentrancy lock setup(重入锁系统）
	uint256 private _status;
	uint256 private constant _NOT_ENTERED = 1; //函数当前未被使用——可以使用
	uint256 private constant _ENTERED = 2; //已经有人在使用这个函数——组织再次使用

	constructor() {
		_status = _NOT_ENTERED;//初始状态
	}

	 // Custom nonReentrant modifier — locks the function during execution
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