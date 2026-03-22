//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

// 继承了 BaseDepositBox 所有内容。
import "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}
