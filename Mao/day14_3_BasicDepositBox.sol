// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_2_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    
  constructor(address initialOwner) BaseDepositBox(initialOwner) {}
    //识别金库类型
    //pure：它不读取或写入任何存储——它只是返回一个硬编码的字符串。
    //override：它（当前函数）正在重写在 IDepositBox 中声明的抽象 getBoxType() 函数（并且该函数在 BaseDepositBox 中未被实现）。
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}
