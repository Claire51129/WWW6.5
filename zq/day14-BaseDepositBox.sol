//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
abstract contract BaseDepositBox is IDepositBox {
    address private owner;
    string private secret;
    uint256 private depositTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner); 
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }
    // 返回当前金库所有者
    function getOwner() public view override returns (address) {
        return owner;
    }
    // 允许当前所有者转移所有权
    function transferOwnership(address newOwner) external virtual  override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    // 存储字符串在金库中
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }
    // 所有者检索存储的秘密
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }
    // 返回金库部署的时间
    function getDepositTime() external view virtual  override returns (uint256) {
        return depositTime;
    }
}