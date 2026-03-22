// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

// 代理合约 - 可升级合约的核心
contract SubscriptionStorage is SubscriptionStorageLayout {

    // 仅所有者可调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 构造函数 - 部署时指定第一个逻辑合约的地址
    constructor(address _logicContract) {
        owner = msg.sender;              // 部署者成为所有者
        logicContract = _logicContract;  // 设置初始逻辑合约
    }

    // 升级逻辑合约 - 把"后台员工"换成新人
    // 只改了一个地址，用户的数据（subscriptions、planPrices 等）完全不受影响
    // 这就是可升级合约的精髓：逻辑可以换，数据永远在
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    // fallback 函数 - 整个代理模式的灵魂
    // 当用户调用一个这个合约上不存在的函数时（比如 subscribe、cancel 等业务函数），
    // Solidity 找不到对应函数，就会自动进入 fallback
    // fallback 把这个调用原封不动地转发给逻辑合约执行
    fallback() external payable {
        address impl = logicContract; // 拿到当前逻辑合约的地址

        // assembly 块：直接写 EVM 底层指令（Yul 语言）
        // 为什么用 assembly？因为 Solidity 层面无法实现"透明转发任意函数调用"
        // 必须用底层指令手动操作 calldata 和 returndata
        assembly {
            // 第一步：把用户发来的完整调用数据复制到内存
            // calldatacopy(目标位置, 源位置, 数据长度)
            // 从 calldata 的第 0 字节开始，复制全部内容到内存的第 0 位置
            calldatacopy(0, 0, calldatasize())

            // 第二步：用 delegatecall 调用逻辑合约
            // delegatecall 和 call 的关键区别：
            // - call：在目标合约的上下文中执行，读写目标合约的存储
            // - delegatecall：在当前合约（代理）的上下文中执行，读写代理合约的存储
            // 也就是说，逻辑合约的代码跑的是代理合约的数据
            // 类比：请了一个外卖厨师（逻辑合约）来你家厨房（代理合约）做菜
            //       厨师用的是你家的食材和锅碗（你的存储），做完菜留在你家
            //       换一个厨师（升级），厨房和食材还是你的
            // 参数：gas(), 目标地址, 输入数据起始位置, 输入数据长度, 输出位置, 输出长度
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // 第三步：把逻辑合约的返回数据复制到内存
            // returndatacopy(目标位置, 源位置, 数据长度)
            returndatacopy(0, 0, returndatasize())

            // 第四步：根据执行结果决定返回还是回滚
            switch result
            case 0 {
                // result == 0 表示调用失败，回滚并返回错误信息
                revert(0, returndatasize())
            }
            default {
                // result != 0 表示调用成功，把返回数据传回给用户
                return(0, returndatasize())
            }
        }
    }

    // 接收纯 ETH 转账（没有调用数据时触发）
    receive() external payable {}
}