//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./Day14-IDepositBox.sol";

//BaseDepositBox是母合约 金库通用基础版 
//abstract 不完整合约 没有把接口里的有的function都写上 boxType每个子合约不一样
abstract contract BaseDepositBox is IDepositBox {

    address private owner;
    address private manager;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    constructor(address _owner, address _manager){
        owner = _owner;
        manager = _manager;
        //owner = msg.sender;
        depositTime = block.timestamp;

    }

    modifier onlyOwner(){
        //require(owner == msg.sender, "Not the owner");
        require(msg.sender == owner || msg.sender == manager,"not authorized");

        _;
    }

    function getOwner() public view override returns (address){
        return owner;

    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Invalid Address");
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