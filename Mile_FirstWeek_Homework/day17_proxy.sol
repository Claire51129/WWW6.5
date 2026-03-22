// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入基类，路径必须准确
import "./day17_storagelayout.sol";

/**
 * @title day17_proxy
 * @dev 代理合约实现。
 *      文件名: day17_proxy.sol
 *      合约名: day17_proxy
 */
contract day17_proxy is day17_storagelayout {
    
    // 仅管理员修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    // 构造函数：初始化管理员和第一个逻辑合约地址
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }
    
    // 升级逻辑合约地址
    function upgradeTo(address _newLogic) external onlyOwner {
        require(_newLogic != address(0), "New logic address cannot be zero");
        logicContract = _newLogic;
    }
    
    // Fallback 函数：拦截所有调用并转发 (Delegatecall)
    fallback() external payable {
        address impl = logicContract;
        
        assembly {
            // 复制 calldata 到内存
            calldatacopy(0, 0, calldatasize())
            
            // 执行 delegatecall
            // gas(), impl, 0, calldatasize(), 0, 0
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            
            // 获取返回数据大小
            let size := returndatasize()
            
            // 复制返回数据到内存
            returndatacopy(0, 0, size)
            
            // 根据结果决定 return 还是 revert
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }
    
    // 接收 ETH
    receive() external payable {}
}