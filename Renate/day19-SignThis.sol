// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SignatureUtils - 签名工具库
// 提供 ECDSA 签名验证相关的辅助函数
// 简化了以太坊签名的创建和验证过程
library SignatureUtils {

    // 获取消息哈希
    // 对原始数据进行 keccak256 哈希
    // _user: 用户地址
    // 返回: 消息哈希值
    function getMessageHash(address _user) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_user));
    }

    // 获取以太坊标准签名消息哈希
    // 在原始消息哈希前添加以太坊签名前缀
    // 这是以太坊个人签名标准（EIP-191）
    // _messageHash: 原始消息哈希
    // 返回: 带前缀的以太坊签名消息哈希
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    // 从签名中恢复签名者地址
    // _ethSignedMessageHash: 以太坊签名消息哈希
    // _signature: 签名数据（65字节）
    // 返回: 恢复出的签名者地址
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        // 将签名分解为 r, s, v 三个部分
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        // 使用 ecrecover 恢复签名者地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // 将签名分解为 r, s, v 三个组件
    // 以太坊签名的标准格式: r (32字节) + s (32字节) + v (1字节) = 65字节
    // sig: 完整签名数据
    // 返回: (r, s, v)
    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // 验证签名长度正确
        require(sig.length == 65, "Invalid signature length");

        // 使用内联汇编提取 r, s, v
        assembly {
            // r 位于 sig 偏移 32 字节处（跳过长度字段）
            r := mload(add(sig, 32))

            // s 位于 sig 偏移 64 字节处
            s := mload(add(sig, 64))

            // v 位于 sig 偏移 96 字节处（最后一个字节）
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

// SignThis - 基于签名的活动参与合约
// 演示如何使用链下签名实现访问控制
// 组织者可以签名授权特定用户参与活动
contract SignThis {
    // 组织者地址（拥有签名权限）
    address public organizer;

    // 记录已参与活动的用户
    // key: 用户地址
    // value: 是否已参与
    mapping(address => bool) public hasEntered;

    // 构造函数 - 设置组织者为部署者
    constructor() {
        organizer = msg.sender;
    }

    // 参与活动
    // signature: 组织者对用户地址的签名
    // 用户需要提供有效的签名才能参与活动
    function enterEvent(bytes memory signature) external {
        // 验证用户尚未参与
        require(!hasEntered[msg.sender], "Already entered");

        // 步骤 1: 重新创建被签名的消息哈希（用户的地址）
        bytes32 messageHash = SignatureUtils.getMessageHash(msg.sender);

        // 步骤 2: 添加以太坊签名前缀，得到标准以太坊签名消息
        bytes32 ethSignedMessageHash = SignatureUtils.getEthSignedMessageHash(messageHash);

        // 步骤 3: 从签名中恢复签名者地址
        address signer = SignatureUtils.recoverSigner(ethSignedMessageHash, signature);

        // 步骤 4: 验证签名者是组织者
        require(signer == organizer, "Invalid signature");

        // 步骤 5: 标记用户已参与
        hasEntered[msg.sender] = true;
    }
}

// 签名验证流程说明:
//
// 链下签名过程（组织者执行）:
// 1. 获取用户地址: userAddress
// 2. 计算消息哈希: keccak256(userAddress)
// 3. 使用私钥签名（自动添加以太坊前缀）
// 4. 将签名提供给用户
//
// 链上验证过程（本合约执行）:
// 1. 重新计算消息哈希
// 2. 添加以太坊前缀
// 3. 使用 ecrecover 恢复签名者
// 4. 验证签名者是组织者
//
// 使用场景:
// - 白名单访问控制
// - 无 Gas 空投领取
// - 链下授权链上执行
// - 元交易（Meta-transactions）
