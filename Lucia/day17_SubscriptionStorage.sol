// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";
contract SubscriptionStorage is SubscriptionStorageLayout{
    modifier onlyOwner(){
        require(msg.sender == owner, " Not owner");
        _;    
    }

    constructor (address _logicContract){
        owner = msg.sender;
        logicContract = _logicContract;
    }
    //struct 结构体 construct构造函数

    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }


    fallback() external payable{
        //fallback()调用不存在的函数时会被触发
        address impl = logicContract;
        require(impl != address(0),"logic ccontract not set");

        assembly{
            calldatacopy(0,0,calldatasize())
            //calldatacopy(拷贝到内存哪个位置，从用户数据的哪个位置开始拷贝，拷贝多长）
            let result := delegatecall(gas(), impl, 0, calldatasize(),0,0)
            //delegatecall(本次调用油费，转发给谁（逻辑合约的地址），请求数据在内存位置，数据长度，0，0）
            //把delegatecall执行完后向栈顶压入一个数字 （1代表成功，0代表失败）存入result变量
            returndatacopy(0,0,returndatasize())

            switch result//检查result值
            case 0 { revert(0, returndatasize())}//错误情况
            default { return(0, returndatasize())}
        }
    }
    receive() external payable {}
    }

