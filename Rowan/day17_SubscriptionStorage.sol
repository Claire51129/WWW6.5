// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/*
    这是 Proxy 合约
    所有用户都与这个合约交互

    主要职责：
    1 保存所有数据
    2 delegatecall 到逻辑合约
    3 支持升级逻辑合约
*/

contract SubscriptionStorage is SubscriptionStorageLayout {

    // 只有管理员才能执行
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /*
        构造函数
        部署 Proxy 时执行一次
    */
    constructor(address _logicContract) {

        // 设置管理员
        owner = msg.sender;

        // 设置初始逻辑合约
        logicContract = _logicContract;
    }

    /*
        升级逻辑合约
        只修改 logicContract 地址
        存储数据不会改变
    */
    function upgradeTo(address _newLogic) external onlyOwner {

        logicContract = _newLogic;
    }

    /*
        fallback 函数
        当调用 Proxy 中不存在的函数时触发

        所有调用都会转发到逻辑合约
    */
    fallback() external payable {

        // 当前逻辑合约地址
        address impl = logicContract;

        require(impl != address(0), "Logic contract not set");

        assembly {

            // 把 calldata 复制到内存
            calldatacopy(0, 0, calldatasize())

            // delegatecall 到逻辑合约
            let result := delegatecall(
                gas(),
                impl,
                0,
                calldatasize(),
                0,
                0
            )

            // 复制返回数据
            returndatacopy(0, 0, returndatasize())

            // 判断调用是否成功
            switch result
            case 0 {
                // 失败 -> revert
                revert(0, returndatasize())
            }
            default {
                // 成功 -> 返回数据
                return(0, returndatasize())
            }
        }
    }

    /*
        receive 函数
        允许直接接收 ETH
    */
    receive() external payable {}
}
