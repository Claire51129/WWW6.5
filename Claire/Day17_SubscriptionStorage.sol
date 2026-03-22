// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本

import "./Day17_SubscriptionStorageLayout.sol";
// 导入存储布局合约
// 继承这个合约，获得所有存储变量

contract SubscriptionStorage is SubscriptionStorageLayout {
// 定义一个合约，叫"订阅存储代理"
// 继承 SubscriptionStorageLayout，所以拥有：
// - logicContract（逻辑合约地址）
// - owner（所有者地址）
// - subscriptions（用户订阅数据）
// - planPrices（套餐价格）
// - planDuration（套餐时长）

    modifier onlyOwner() {
    // 定义一个修饰符：只有所有者能调用
        require(msg.sender == owner, "Not owner");
        // 检查调用者是不是owner
        _;
        // 检查通过后，继续执行原函数
    }

    constructor(address _logicContract) {
    // 构造函数：部署时自动执行
        owner = msg.sender;
        // 部署者成为所有者
        
        logicContract = _logicContract;
        // 设置初始的逻辑合约地址
    }

    function upgradeTo(address _newLogic) external onlyOwner {
    // 升级函数：更换逻辑合约
    // external onlyOwner：只能外部调用，且只有所有者能调用
        
        logicContract = _newLogic;
        // 把逻辑合约地址更新为新地址
        // 之后所有调用都会转发到新逻辑合约
    }

    fallback() external payable {
    // fallback函数：当调用不存在的函数时，会执行这里
    // 这是代理合约的核心！所有调用都会进入这里
    // external payable：可以接收ETH
        
        address impl = logicContract;
        // 获取当前逻辑合约地址
        
        require(impl != address(0), "Logic contract not set");
        // 确保逻辑合约已设置

        assembly {
        // assembly：内联汇编，更底层的操作
        // 这里实现 delegatecall（委托调用）
        
            calldatacopy(0, 0, calldatasize())
            // 复制调用数据到内存位置0
            // 参数：目标位置, 源位置, 数据长度
            // 作用：把用户传来的函数调用数据复制到内存
            
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            // delegatecall：委托调用
            // gas()：当前剩余gas
            // impl：目标合约地址（逻辑合约）
            // 0, calldatasize()：输入数据位置和长度（刚复制到内存0位置）
            // 0, 0：输出数据位置和长度（暂时为0）
            // 返回值：result，0表示失败，非0表示成功
            
            returndatacopy(0, 0, returndatasize())
            // 复制返回数据到内存位置0
            // 作用：把逻辑合约的返回值复制出来
            
            switch result
            // 根据result的值进行分支
            case 0 { revert(0, returndatasize()) }
            // 如果result=0（调用失败），回滚交易
            default { return(0, returndatasize()) }
            // 如果result≠0（调用成功），返回数据
        }
    }

    receive() external payable {}
    // receive函数：当接收ETH时调用（没有数据的情况）
    // 空的receive，允许合约接收ETH
}