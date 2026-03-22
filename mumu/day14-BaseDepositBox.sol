// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox{
    address private owner;
    string private secret;
    uint256 private depositTime;

    // 事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    modifier onlyOwner(){
        require(msg.sender == owner, "Not the Box owner");
        _;
    }

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    // constructor(address _owner){
    //     owner = _owner;
    //     depositTime = block.timestamp;
    // }


    function getOwner() public view override returns (address){
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns(string memory){
        return secret;
    }

    function getDepositTime() external view virtual override returns(uint256){
        return depositTime;
    }

}

/**
知识点：
1. abstract 关键字声明抽象合约，抽象合约不能单独部署
2. 一个函数中，可以同时存在virtual和override 关键字。表示是重写了某个母合约，同时也允许该合约的子合约重写
 */