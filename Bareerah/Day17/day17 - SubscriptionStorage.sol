// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17 - SubscriptionStorageLayout.sol";

// 代理合约
// 这是用户将与之交互的合约，但它会将所有实际工作委托给逻辑合约（day17 - SubscriptionStorageLayout.sol）
contract SubscriptionStorage is SubscriptionStorageLayout{
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner!");
        _;
    }

    constructor(address _loginContract){
        owner = msg.sender;
        logicContract = _loginContract;
    }

    // 逻辑升级模块
    function upgradeTo(address _newLogic) external onlyOwner{
        logicContract = _newLogic;
    }

    // 当用户调用此代理合约中不存在的函数时会被触发
    // 比如每次用户尝试与我们其他合约中的函数(如 subscribe() 或 isActive())交互时
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");
        
        // 内联汇编
        assembly{
            // 将输入数据（函数签名+参数）复制到内存槽 0
            calldatacopy(0, 0, calldatasize())

            // *delegatecall 运行逻辑代码，但使用此代理的存储和此代理的上下文
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // 将逻辑合约执行返回的任何内容复制到内存中
            returndatacopy(0, 0, returndatasize())
            
            // 调用失败回退并返回错误，否则将结果返回给原始调用者
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

    // 允许代理接受原始 ETH 转账
    receive() external payable { }
}