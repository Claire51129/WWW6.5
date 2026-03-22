// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

/*
    IDepositBox 接口（Interface）

    接口用于定义一组必须实现的函数规则。
    任何实现这个接口的合约，都必须包含这些函数。

    在我们的金库系统中：
    BasicDepositBox
    PremiumDepositBox
    TimeLockedDepositBox

    都必须实现这些函数。
*/

interface IDepositBox {

    /*
        返回当前金库的所有者地址
        view 表示该函数只读取状态，不修改区块链数据
    */
    function getOwner() external view returns(address);

    /*
        转移金库所有权

        参数:
        newOwner - 新的所有者地址
    */
    function transferOwnership(address newOwner) external;

    /*
        存储一个秘密字符串到金库中

        参数:
        secret - 用户想要存储的秘密信息

        calldata:
        表示函数参数来自外部调用，
        使用 calldata 比 memory 更省 gas
    */
    function storeSecret(string calldata secret) external;

    /*
        获取已经存储的秘密

        view 表示不会修改区块链状态
        返回 string 类型的秘密内容
    */
    function getSecret() external view returns (string memory);

    /*
        返回金库的类型

        不同的金库类型会返回不同的字符串，例如：
        "Basic"
        "Premium"
        "TimeLocked"

        pure 表示函数既不读取也不修改区块链数据
    */
    function getBoxType() external pure returns(string memory);

    /*
        返回金库创建的时间（Unix 时间戳）

        uint256 表示时间戳的整数值
    */
    function getDepositTime() external view returns(uint256);
}