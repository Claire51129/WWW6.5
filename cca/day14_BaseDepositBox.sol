// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day14_IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox{
    //abstract表示这个合约不能直接部署 只处理通用逻辑
    //没有写完整接口中所有功能 如getBoxType() 函数 子合约会有自己的版本
    address private owner;
    string private secret;
    uint256 private depositTime;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }
    /*constructor(address initialOwner) {
        require(initialOwner != address(0), "Invalid address");
        owner = initialOwner;
        depositTime = block.timestamp;
    }*/

    modifier onlyOwner(){
        require(owner == msg.sender, "Not the owner");
        _;
    }

    function getOwner() public view override returns(address){
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function storeSecret(string calldata _secret)external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns (string memory){
        return secret;
    }

    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
        return depositTime;
    }
}