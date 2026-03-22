// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    导入 Day14 的接口文件

    特别注意！！！因为文件名已经改为：
    day14_IDepositBox.sol

    所以 import 也必须对应修改
*/
import "./day14_IDepositBox.sol";

/*
    BaseDepositBox 抽象合约

    abstract 表示这是一个抽象合约：
    - 不能直接部署
    - 只作为其他合约的基础模板

    这个合约实现了 IDepositBox 接口中的大部分功能
    但没有实现 getBoxType()

    因此：
    BasicDepositBox
    PremiumDepositBox
    TimeLockedDepositBox

    需要继承它并实现 getBoxType()
*/
abstract contract BaseDepositBox is IDepositBox {

    // 金库所有者地址
    address private owner;

    // 存储的秘密字符串
    string private secret;

    // 金库创建时间（Unix 时间戳）
    uint256 private depositTime;

    /*
        事件：当所有权发生转移时触发
        indexed 可以让前端更容易搜索日志
    */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /*
        事件：当存储新的秘密时触发
    */
    event SecretStored(address indexed owner);

    /*
        构造函数

        合约部署时自动执行一次
        设置：
        - owner = 部署者地址
        - depositTime = 当前区块时间
    */
    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    /*
        修饰符：onlyOwner

        限制函数只能由金库所有者调用
    */
    modifier onlyOwner(){
        require(owner == msg.sender, "Not the owner");
        _;
    }

    /*
        获取当前金库所有者
        override 表示这是对接口函数的实现
    */
    function getOwner() public view override returns (address){
        return owner;
    }

    /*
        转移金库所有权

        virtual 表示子合约可以重写这个函数
        onlyOwner 确保只有当前 owner 可以执行
    */
    function transferOwnership(address newOwner) external virtual override onlyOwner{

        // 防止转移到零地址
        require(newOwner != address(0), "Invalid Address");

        // 触发事件
        emit OwnershipTransferred(owner, newOwner); 

        // 更新所有者
        owner = newOwner;
    }

    /*
        存储秘密

        calldata 用于外部函数参数，节省 gas
        只有 owner 可以调用
    */
    function storeSecret(string calldata _secret) external virtual override onlyOwner{

        // 更新秘密
        secret = _secret;

        // 记录事件
        emit SecretStored(msg.sender);
    }

    /*
        获取秘密

        onlyOwner 保证只有 owner 可以读取
    */
    function getSecret() public view virtual override onlyOwner returns (string memory){
        return secret;
    }

    /*
        获取金库创建时间

        返回部署合约时记录的时间戳
    */
    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }

}