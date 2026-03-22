// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象母合约
import "./day14_BaseDepositBox.sol";

/**
 * @dev BasicDepositBox 是一个具体的子合约。
 * 它继承了 BaseDepositBox 母类。
 * 因为它实现了母类中所有未完成的函数，所以它不再是抽象的，可以直接部署到链上。
 */
contract BasicDepositBox is BaseDepositBox {

    //使用 pure 是因为这个函数既不读取也不修改链上状态，只是返回一个常量
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }

}