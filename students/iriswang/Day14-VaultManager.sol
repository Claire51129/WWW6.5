// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day14-IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {
    address public owner;
    string public metadata;
    string private secret;
    uint256 public depositTime;

    constructor(string memory _metadata) {
        owner = msg.sender;
        metadata = _metadata;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function storeSecret(string memory _secret) external override onlyOwner {
        secret = _secret;
    }

    function _getSecret() internal view returns (string memory) {
        return secret;
    }

    // 👇 添加 virtual 关键字，允许子类重写
    function getSecret() external view virtual override onlyOwner returns (string memory) {
        return _getSecret();
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }

    function getBoxType() external pure virtual override returns (string memory);
}
