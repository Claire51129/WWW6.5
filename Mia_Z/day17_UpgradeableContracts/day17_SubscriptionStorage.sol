// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";


//导入共享的存储布局——这确保了代理与逻辑合约具有相同的变量结构。 
//如果你还记得，delegatecall 意味着代码从逻辑合约运行但存储属于代理，所以两者必须共享完全相同的布局
contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

/** *
 * ### 什么是 `fallback()`？

- 它是一个特殊函数，当用户调用此代理合约中**不存在的函数**时会被触发。
- 这很完美，因为这个代理**自身没有业务逻辑**。
- 所以，每次用户尝试与我们其他合约中的函数(如 `subscribe()` 或 `isActive()`)交互时，都会触发这个函数。.
*/
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

