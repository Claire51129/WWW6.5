// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionStorage is SubscriptionStorageLayout {//此合约继承母合约
    
    //保护敏感函数，如升级函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;//指定第一个逻辑合约
    }

    //后续可以升级的关键
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;//将v1 = v2
    }

    //特殊函数，当用户调用的函数本合约里没有时就会触发 
    fallback() external payable {
        address impl = logicContract;//impl = implementation 干活的合约
        require(impl != address(0), "Logic contract not set");//地址不能不存在

        assembly {
            calldatacopy(0, 0, calldatasize())
            //将用户的请求存起来 calldatacopy复制调用数据  calldatacopy( 内存位置, 数据开始位置, 复制长度 )
            //内存位置：从内存第 0 号位置开始放数据   数据开始位置：从用户数据的第 0 位开始拿
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            //delegatecall = 让别人干活，用我的数据
            returndatacopy(0, 0, returndatasize())
            //复制结果数据

            switch result
            case 0 { revert(0, returndatasize()) }
            //case 0是如果结果是失败  如果 result = 0（失败了），就回滚、报错、把错误信息退回去！
            default { return(0, returndatasize()) }
            //否则（就是成功了），把结果返回给用户！  结果数据存在0里
        }
    }

    //一个安全网，允许代理接受原始 ETH 转账
    receive() external payable {}
}
