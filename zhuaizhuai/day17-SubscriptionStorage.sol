// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

// 代理合约：地址永远不变，负责转发请求给逻辑合约
// 数据存在这里，逻辑合约可以随时升级
contract SubscriptionStorage is SubscriptionStorageLayout {
    
    // 只有owner才能操作
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // 部署时：设置owner和第一个逻辑合约地址
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract; // 指向V1逻辑合约
    }
    
    // 升级函数：只有owner能换逻辑合约
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic; // 改成V2地址，升级完成！
    }
    
    // fallback：当用户调用代理合约里不存在的函数时自动触发
    // 比如用户调用subscribe()，代理合约没有这个函数
    // → 触发fallback → 转发给逻辑合约
    fallback() external payable {
        address impl = logicContract; // 找到当前逻辑合约地址
        require(impl != address(0), "Logic contract not set");
        
        assembly {
            // 复制用户发来的所有数据
            calldatacopy(0, 0, calldatasize())
            
            // delegatecall：用逻辑合约的代码，但数据存在代理合约里！
            // 就像借别人的食谱，但在自己家里做菜
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            
            // 复制返回的数据
            returndatacopy(0, 0, returndatasize())
            
            // 判断是否成功
            switch result
            case 0 { revert(0, returndatasize()) }  // 失败→回滚
            default { return(0, returndatasize()) }  // 成功→返回结果
        }
    }
    
    // 接收ETH
    receive() external payable {}
}
