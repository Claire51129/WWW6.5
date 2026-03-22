// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

//代理合约
contract SubscriptionStorage is SubscriptionStorageLayout//继承
{
    modifier onlyOwner() 
    {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) 
    {
        owner = msg.sender;
        logicContract = _logicContract;//传入初始逻辑合约的地址
    }

    //将 logicContract 更新为指向一个新合约，存储保持不变，使用新的逻辑
    function upgradeTo(address _newLogic) external onlyOwner 
    {
        logicContract = _newLogic;
    }

    fallback() external payable //当用户调用此代理合约中不存在的函数时会被触发
    {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        assembly 
        {
            calldatacopy(0, 0, calldatasize())//将输入数据复制到内存
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            //在逻辑合约（impl）上运行这个输入，但存储在当前合约
            returndatacopy(0, 0, returndatasize())
            //将逻辑合约执行返回的任何内容复制到内存中

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
            //调用成功，将结果返回给原始调用者——就像代理自己执行了它一样
        }
    }

    receive() external payable {}//一个安全网，允许代理接受原始 ETH 转账
}
