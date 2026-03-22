// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

/**
  @notice 功能插件库合约 代理合约
 */

contract SubscriptionStorage is SubscriptionStorageLayout{

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract){
        owner = msg.sender;
        logicContract = _logicContract;
    }

    // 升级函数
    function upgradeTo(address _newLogic) external onlyOwner{
        // 检查合约地址
        require(_newLogic != address(0), "address cannot be zero");

        logicContract = _newLogic;
    }

    // 核心函数——代理调用所有函数
    fallback()external payable{
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        assembly {
            //指令： calldatacopy(t, f, s)，表示将数据从 f 复制到内存 t，长度为 s
            //解说： 这一步是将用户传入的所有输入数据（包括函数签名和参数）从 calldata 完整地复制到内存的 0 号槽位
            calldatacopy(0,0,calldatasize())

            // delegatecall(g, a, in, insize, out, outsize)
            // 在impl合约上运行 用户传入的指定 内容. 从0号槽位读取 insize 长度
            // 但是使用当前合约的存储空间和上下文（msg.sender 和 msg.value保持不变）
            let result := delegatecall(gas(),impl, 0, calldatasize(), 0, 0)

            // same as calldatacopy
            returndatacopy(0,0,returndatasize())

            switch result
            // 回滚，并将返回的信息抛出
            case 0 {revert(0, returndatasize()) }
            default {return(0, returndatasize()) }
        }
    }

    // 一个安全网，允许代理接受原始的ETH转帐
    receive() external payable{}
    
}

/**
拓展：
    添加时间锁：升级需要等待24小时
    实现多签升级：需要多个管理员确认
    添加版本管理：跟踪逻辑合约版本历史
    实现回滚功能：可以回退到之前版本
    添加升级事件：记录所有升级操作
    使用OpenZeppelin的代理实现
 */