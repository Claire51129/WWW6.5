// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 内联定义接口和抽象合约（删除import）
interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string memory secret) external;
    function getsecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}

abstract contract BaseDepositBox is IDepositBox {
    address public owner;
    string public metadata;
    string internal secret;
    uint256 public depositTime;

    constructor(string memory _metadata) {
        owner = msg.sender;
        metadata = _metadata;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "BaseDepositBox: not owner");
        _;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function storeSecret(string memory _secret) external override onlyOwner {
        secret = _secret;
    }

    function getBoxType() external pure virtual override returns (string memory);
}

// 时间锁盒子合约逻辑
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;

    constructor(string memory _metadata, uint256 lockDuration) BaseDepositBox(_metadata) {
        unlockTime = block.timestamp + lockDuration;
    }

    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "TimeLockedDepositBox: still locked");
        _;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    function getsecret() external view override onlyOwner timeUnlocked returns (string memory) {
        return secret;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "TimeLockedDepositBox: invalid owner");
        owner = newOwner;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }
}