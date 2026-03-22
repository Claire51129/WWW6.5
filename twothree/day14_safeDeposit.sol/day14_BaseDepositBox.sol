// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 内联定义接口（删除import）
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