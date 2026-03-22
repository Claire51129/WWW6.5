//基础保险箱：所有保险箱的基础模板
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import {IDepositBox} from "./day14-IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {    //继承接口：BaseDepositBox必须实现IDepositBox接口

    address private owner;    //保险箱主人
    string private secret;    //存的秘密
    uint256 private depositTime;    //记录存入时间

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);    //所有权转移事件：当主人改变时记录
    event SecretStored(address indexed owner);    //存储秘密事件：记录谁存了秘密

    constructor(){    //构造函数：创建保险箱时
        owner = msg.sender;    //owner=创建者
        depositTime = block.timestamp;    //depositTime=当前时间
    }

    modifier onlyOwner(){    //权限控制：只有主人才能操作
        require(owner == msg.sender, "Not the owner");
        _;
    }

    //获取主人
    function getOwner() public view override returns (address){
        return owner;
    }

    //转移所有权
    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Invalid Address");    //newowner不能是地址0
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    //存秘密：保存秘密，记录事件
    function storeSecret(string calldata _secret)external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    //获取秘密：只有owner可查看
    function getSecret() public view virtual override onlyOwner returns (string memory){
        return secret;
    }

    //获取存入时间
    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
        return depositTime;
    }

// abstract 抽象合约
// inheritance 继承
//modifier 修饰器





}