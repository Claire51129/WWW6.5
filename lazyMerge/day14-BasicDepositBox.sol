//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./day14-BaseDepositBox.sol";

// 这里是最简单的特定类型存储箱
contract BasicDepositBox is BaseDepositBox {
    // external 仅用于从合约外部调用
    // pure 不写入存储数据
    // override 表重写
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}
