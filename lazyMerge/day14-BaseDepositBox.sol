//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import "./day14-IDepositBox.sol";


// 添加 abstract 表示这个合约不能直接部署
// 这里只处理通用逻辑，个性化处理自己实现
abstract contract BaseDepositBox is IDepositBox {

    address private owner; // 所有者
    string  private secret; // 存储什么
    uint256 private depositTime; // 存储的事件

    // 当转移所有权时触发
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // 存储时触发
    event SecretStored(address indexed owner);

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "Not the owner");
        _;
    }

    function getOwner() public view override returns (address){
        return owner;
    }

    // 所有权转移 这里重写了
    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Invalid Address");
        emit OwnershipTransferred(owner, newOwner); 
        owner = newOwner;
    }

    // 存储函数 重写了
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
