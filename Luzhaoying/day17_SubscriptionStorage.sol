 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SubscriptionStorageLayout} from "./day17_SubscriptionStorageLayout.sol";

//此合约继承了layout的功能，用来与用户交互
contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }
    //此函数将logicContract 更新为指向一个新合约，可在不触及用户数据或要求人们重新部署的情况下修复错误、添加功能或重构代码
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }
    //当用户调用此代理合约中不存在的函数时会被触发
    fallback() external payable {
        //确保已设置逻辑合约
        address impl = logicContract;
        //将其存储在 `impl` 中
        require(impl != address(0), "Logic contract not set");

        assembly {
            //将输入数据（函数签名 + 参数）复制到内存槽 0
            calldatacopy(0, 0, calldatasize())
            //- 我们在说：“嘿，在逻辑合约（`impl`）上运行这个输入…”
            // `delegatecall` 运行逻辑代码，但使用**此代理的存储**和**此代理的上下文**
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            //将逻辑合约执行返回的任何内容复制到内存中
            returndatacopy(0, 0, returndatasize())
            //如果逻辑调用失败，我们回退（revert）并返回错误
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    //允许代理接受原始 ETH 转账
    receive() external payable {}
}

