// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";//每个合约都有基本规范

abstract contract BaseDepositBox is IDepositBox {//创建一个抽象合约，无法直接部署的合约
    address private owner;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);//设定所有权转让事件
    event SecretStored(address indexed owner);//储存新秘密时触发

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    constructor(address initialOwner) {//构造函数，合约的第一位主人地址
        require(initialOwner != address(0), "Owner cannot be zero address");
        owner = initialOwner;
        depositTime = block.timestamp;
    }

    //返回金库当前所有者
    function getOwner() public view override returns (address) {
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner {//人为转让，是在合约外部人为进行而不是机器来跑，所以用external
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    //所有者将字符串存储在金库中
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    //获取秘密
    function getSecret() public view virtual override onlyOwner returns (string memory) {//override 重写母合约，同时virtual允许下一级修改
        return secret;
    }

    //返回金库部署时间
    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }
}