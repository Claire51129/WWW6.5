// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    导入 BaseDepositBox 抽象合约
*/
import "./day14_BaseDepositBox.sol";

/*
    BasicDepositBox 合约

    这是最基础的金库类型。
    它继承 BaseDepositBox 合约，从而自动获得：

    - owner 管理
    - secret 存储
    - 存储时间记录
    - 权限控制 (onlyOwner)

    这个合约只需要实现接口中唯一未实现的函数：
    getBoxType()
*/
contract BasicDepositBox is BaseDepositBox {

    /*
        返回金库类型

        pure 表示：
        - 不读取区块链数据
        - 不修改区块链数据

        override 表示：
        这是对父合约或接口函数的实现
    */
    function getBoxType() external pure override returns (string memory) {

        // 返回当前金库类型
        return "Basic";
    }
}