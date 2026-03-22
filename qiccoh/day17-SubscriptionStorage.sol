 //SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";
//继承
contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
//  构造函数
    constructor(address _logicContract) {
        owner = msg.sender;//部署者成为所有者
        logicContract = _logicContract;//传入初始逻辑合约的地址——通常是 SubscriptionLogicV1
    }
// 逻辑升级？？
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }
// 特殊函数，当用户调用此代理合约中不存在的函数时会被触发
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");
// 确保已设置逻辑合约？？？
        assembly {
            calldatacopy(0, 0, calldatasize())//复制调用数据（calldata）到内存
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
// 一个安全网，允许代理接受原始 ETH 转账
    receive() external payable {}
}

