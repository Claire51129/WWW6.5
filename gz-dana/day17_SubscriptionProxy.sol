// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * Day 17 - 代理合约
 * 
 * 这是用户唯一需要交互的合约地址，永不改变。
 * 
 * 职责：
 * 1. 保存所有状态数据（继承 StorageLayout）
 * 2. 管理逻辑合约地址（可升级）
 * 3. 通过 fallback 使用 delegatecall 转发所有调用到逻辑合约
 * 
 * 关键：
 * - 使用内联汇编实现高效的 delegatecall
 * - 保持 msg.sender 和 msg.value 不变
 * - 代码在逻辑合约执行，数据写在代理合约
 */
contract SubscriptionProxy is SubscriptionStorageLayout {
    
    // 升级事件
    event Upgraded(address indexed previousLogic, address indexed newLogic, uint256 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // 权限修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "SubscriptionProxy: caller is not the owner");
        _;
    }
    
    /**
     * 构造函数：初始化代理合约
     * @param _logicContract V1 逻辑合约地址
     */
    constructor(address _logicContract) {
        require(_logicContract != address(0), "SubscriptionProxy: logic contract is zero address");
        
        owner = msg.sender;
        logicContract = _logicContract;
        version = 1;
        
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    /**
     * 升级逻辑合约
     * @param _newLogic 新的逻辑合约地址（V2）
     */
    function upgradeTo(address _newLogic) external onlyOwner {
        require(_newLogic != address(0), "SubscriptionProxy: new logic is zero address");
        require(_newLogic != logicContract, "SubscriptionProxy: new logic is the same");
        
        address previousLogic = logicContract;
        logicContract = _newLogic;
        version++;
        
        emit Upgraded(previousLogic, _newLogic, version);
    }
    
    /**
     * 获取当前逻辑合约地址
     */
    function getImplementation() external view returns (address) {
        return logicContract;
    }
    
    /**
     * 转移所有权
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "SubscriptionProxy: new owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    /**
     * Fallback 函数：代理所有调用到逻辑合约
     * 
     * 使用内联汇编实现 delegatecall：
     * 1. calldatacopy - 将调用数据复制到内存
     * 2. delegatecall - 在代理合约上下文中执行逻辑合约代码
     * 3. returndatacopy - 将返回数据复制到内存
     * 4. return/revert - 返回结果或回滚
     * 
     * 关键特性：
     * - msg.sender 保持为原始调用者
     * - msg.value 保持不变
     * - 存储使用代理合约的存储
     */
    fallback() external payable {
        address impl = logicContract;
        
        assembly {
            // 将调用数据（calldata）复制到内存位置 0
            // calldatacopy(目标内存位置, calldata起始位置, 复制字节数)
            calldatacopy(0, 0, calldatasize())
            
            // 执行 delegatecall
            // delegatecall(gas剩余, 目标地址, 输入内存起始, 输入大小, 输出内存起始, 输出大小)
            // 输出大小设为 0，因为我们先用 returndatasize() 获取实际大小
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            
            // 将返回数据复制到内存位置 0
            returndatacopy(0, 0, returndatasize())
            
            // 根据 delegatecall 结果决定返回或回滚
            switch result
            case 0 {
                // 调用失败，回滚交易
                // revert(内存起始位置, 大小)
                revert(0, returndatasize())
            }
            default {
                // 调用成功，返回数据
                // return(内存起始位置, 大小)
                return(0, returndatasize())
            }
        }
    }
    
    /**
     * Receive 函数：接收纯 ETH 转账
     */
    receive() external payable {}
}