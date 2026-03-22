// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {

    mapping(address => uint256) public balances;

    // =========================
    // 存款函数
    // =========================
    function deposit() external payable {
        require(msg.value > 0, "Must deposit ETH");
        balances[msg.sender] += msg.value;
    }

    // =========================
    // ❌ 漏洞函数（可被重入攻击）
    // =========================
    function vulnerableWithdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        // ❌ 先转钱（漏洞点）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // ❌ 后更新余额
        balances[msg.sender] = 0;
    }

    // =========================
    // ✅ 安全函数（不需要 import）
    // =========================
    function safeWithdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        // ✅ 先更新余额（CEI模式）
        balances[msg.sender] = 0;

        // 再转钱
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
