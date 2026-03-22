// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

//用户将与之交互的合约,实际工作委托给逻辑合约
contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    //代理合约知道当用户开始与之交互时使用哪个逻辑
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;  //传入初始逻辑合约的地址
    }

    //存储不变：不触及用户数据或要求人们重新部署的情况下修复错误、添加功能或重构代码。
    //逻辑升级：logicContract更新为新的合约
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    //fallback()当用户调用此代理合约中不存在的函数时触发
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        assembly {    //assembly内联汇编块，用于在高级语言中嵌入底层汇编指令
            calldatacopy(0, 0, calldatasize())  //外部调用（比如用户调用合约函数）时传入的原始二进制数据，包含函数选择器、参数等
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)  //在逻辑合约（impl）上运行这个输入,但使用此代理的存储和此代理的上下文
            returndatacopy(0, 0, returndatasize())  //将逻辑合约执行返回的任何内容复制到内存中

            switch result
            case 0 { revert(0, returndatasize()) }  //逻辑调用失败，我们回退（revert）并返回错误
            default { return(0, returndatasize()) } //将结果返回给原始调用者——就像代理自己执行了它一样
        }
    }

    //允许代理接受原始 ETH 转账
    receive() external payable {}
}

