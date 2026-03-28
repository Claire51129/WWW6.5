// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SubscriptionStorageLayout} from "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionStorage is SubscriptionStorageLayout {    //继承存储布局：保证数据结构一致
    modifier onlyOwner() {    //权限控制：只有老板能操作
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;    //部署的人
        logicContract = _logicContract;    // V1地址
    }

    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;    //把大脑从V1换成V2
    }

    fallback() external payable {    //万能接线员：当调用的函数不存在时 → 走这里
        address impl = logicContract;    //找到当前逻辑合约
        require(impl != address(0), "Logic contract not set");    //必须有大脑

        assembly {    //底层操作（可以先当黑盒理解）
            calldatacopy(0, 0, returndatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)   //去logic合约执行代码，但用的是proxy的数据
            returndatacopy(0, 0, returndatasize())    //执行成功就返回

            switch result    //失败就报错
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}    // 用来收钱
}


// 最核心的合约：Proxy合约
// call：在别人那里； delegatecall：在自己这里——借别人的脑子，用自己的身体（数据还是我的）
// fallback：不会的函数 → 自动转发

// logicV1：0xE5f2A565Ee0Aa9836B4c80a07C8b32aAd7978e22
























// import {IDepositBox} from "./day14-IDepositBox.sol";