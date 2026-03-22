// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }//履行对 IDepositBox 接口的承诺 识别金库类型 此处是Basic
    //正在重写IDepositBox 中声明的抽象 getBoxType() 函数（并且该函数在 BaseDepositBox 中未被实现）
}
