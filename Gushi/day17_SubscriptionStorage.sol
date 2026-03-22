// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//代理合约，数据存在这里，调用的是逻辑合约的function
import "./day17_SubscriptionStorageLayout.sol"; //导入蓝图～

contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract; //存逻辑合约的地址
    }

    function upgradeTo(address _newLogic) external onlyOwner { //更新版本
        logicContract = _newLogic;
    }

    fallback() external payable { //用户调用不存在的函数时就会触发fallback，它自身没有业务逻辑
        address impl = logicContract; //
        require(impl != address(0), "Logic contract not set");//检查逻辑合约地址并赋给impl

        assembly {
            calldatacopy(0, 0, calldatasize()) //复制函数签名和参数，固定用法
            //这些固定的0，是因为逻辑和代理合约都用了同一个布局
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0) //将刚才的复制值传到v1调用函数
            returndatacopy(0, 0, returndatasize()) //返回的结果

            switch result
            case 0 { revert(0, returndatasize()) } //调用失败，回滚，告知原因
            default { return(0, returndatasize()) } //调用成功，返回结果
        }
    }

    receive() external payable {} //安全网，接收eth转账
}