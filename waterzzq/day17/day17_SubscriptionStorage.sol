// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17_SubscriptionStorageLayout.sol";

// 代理合约：用户永远和它交互，地址不变
contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this!");
        _;
    }

    // 构造函数：部署时指定初始逻辑合约地址
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    // 升级逻辑合约：只有所有者能调用
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    //  fallback：调用代理不存在的函数时，自动转发给逻辑合约
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set!");

        assembly {
            // 把调用数据复制到内存
            calldatacopy(0, 0, calldatasize())
            // 用delegatecall执行逻辑合约代码，修改代理存储
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            // 把返回结果复制到内存
            returndatacopy(0, 0, returndatasize())
            // 处理结果：成功返回，失败回滚
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // 允许代理接收ETH（用户订阅时支付的ETH）
    receive() external payable {}
}