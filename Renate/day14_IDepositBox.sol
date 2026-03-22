// SPDX-License-Identifier: MIT
// 合约采用MIT开源许可证协议

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本：兼容0.8.x系列

// 存款盒核心接口：定义存款盒的基础功能规范
// 接口特性：仅声明函数签名，无实现逻辑，实现合约需完成所有函数的具体实现
interface IDepositBox {
    // 获取合约所有者地址（view函数：仅读取状态，无修改）
    function getOwner() external view returns(address);

    // 转移合约所有权（参数：新所有者地址）
    function transferOwnership(address newOwner) external;

    // 存储私密信息（calldata修饰参数：节省Gas，仅外部调用可用）
    function storeSecret(string calldata secret) external;

    // 获取存储的私密信息（view函数：仅读取状态，无修改）
    function getSecret() external view returns (string memory);

    // 获取存款盒类型标识（pure函数：无状态读写，仅返回固定标识）
    function getBoxType() external pure returns(string memory);

    // 获取存款/合约创建时间戳（view函数：仅读取状态，返回Unix时间戳）
    function getDepositTime() external view returns(uint256);
}