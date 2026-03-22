// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
abstract contract BaseDepositBox is IDepositBox { // parent sol is IDepositBox
//共享的基础。它会实现接口中定义的大部分逻辑，如秘密存储、所有权和存入时间
    address private owner;
    string private secret; //用户可以安全地存储在该存款箱中的私有字符串 // why this is not a array? 
    uint256 private depositTime; //如果有人想读取private，必须通过提供的公共getter 函数来查
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);
    constructor (address initialOwner){
        require(initialOwner != address(0), "invalid address");
        owner = initialOwner;
        depositTime = block.timestamp;
    // 金库部署时,当前时间（自 Unix 纪元以来的秒数）被记录为存入时间
    }
     modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }
    function getOwner() public view override returns (address) { //why override here?
    return owner;  //IDepositBox 接口所要求的。
    }
    function transferOwnership(address newOwner) external virtual override onlyOwner {//virtual indicates that the function can be overridden by a child contract,This is a common pattern when you want to ensure that the function can be extended or modified by both the parent and child contracts.
    require(newOwner != address(0), "New owner cannot be zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    }
    function storeSecret(string calldata _secret) external virtual override onlyOwner { // calldata，因为在传递字符串参数时，它在 gas 上更便宜
    secret = _secret;
    emit SecretStored(msg.sender);
    }
    function getSecret() public view virtual override onlyOwner returns (string memory) { //标记为 onlyOwner 以确保隐私——其他任何人都无法看到秘密
    return secret;
    }
    function getDepositTime() external view virtual override returns (uint256) {
    return depositTime;
    }

}