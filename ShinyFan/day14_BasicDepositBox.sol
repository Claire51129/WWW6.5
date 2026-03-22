// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {//创建一个新合约，继承 BaseDepositBox 的所有逻辑
    constructor(address initialOwner) BaseDepositBox(initialOwner) {}//BasicDepositBox合约不亲自干活，将地址传回母合约

    //扩展重写函数
    function getBoxType() external pure override returns (string memory) {
        return "Basic";//返回金库类型时Basic
    }
}