// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";

// 抽象合约，没有把接口里规定的所有功能都写完整
abstract contract BaseDepositBox is IDepositBox {
    //状态变量
    address private owner;
    string private secret;
    uint256 private depositTime;


    //事件
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

    //返回金库当前所有者
    function getOwner() public view override returns (address) {
        return owner;
    }

    //移交所有权
    function transferOwnership(address newOwner) external virtual  override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    //储存字符串，calldata的gas更便宜
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    //允许所有者检索
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    //返回时间戳
    function getDepositTime() external view virtual  override returns (uint256) {
        return depositTime;
    }
}
