// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev IDepositBox 是一个母接口（Interface），定义了保险箱合约必须遵循的标准。
 * 任何继承或实现此接口的合约，都必须具体实现以下所有函数。
 */
interface IDepositBox {
    
    // 获取当前保险箱的主人地址
    function getOwner() external view returns (address);

    // 将保险箱的所有权转让给新主人
    // @param newOwner 新主人的地址
    function transferOwnership(address newOwner) external;

    // 存储一段秘密文字到保险箱中
    // @param secret 要加密或保存的字符串
    function storeSecret(string calldata secret) external;

    // 从保险箱中读取之前存储的秘密
    function getSecret() external view returns (string memory);

    // 获取保险箱的类型（例如："铁制"、"电子"）
    // 使用 pure 是因为这个返回值通常是硬编码的字符串，不读取链上状态
    function getBoxType() external pure returns (string memory);

    // 获取存入秘密时的具体时间戳
    function getDepositTime() external view returns (uint256);
    
}

