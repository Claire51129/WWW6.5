// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @title SignThis
 * @dev 演示如何在链上验证 EIP-191 标准的签名。
 * 用户在前端对消息签名，合约在后端验证签名者是否为预期的地址。
 */
contract SignThis {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // 记录消息是否已被处理，防止重放攻击（Replay Attack）
    mapping(bytes32 => bool) public executed;

    event MessageVerified(address indexed signer, string message);

    /**
     * @notice 验证签名并执行逻辑
     * @param message 用户签名的原始字符串消息
     * @param signature 前端生成的 65 字节签名数据 (r, s, v)
     * @param expectedSigner 我们期望的签名者地址（例如管理员或用户本人）
     */
    function verifyAndExecute(
        string calldata message,
        bytes calldata signature,
        address expectedSigner
    ) external {
        // 1. 计算消息的哈希值
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        
        // 2. 检查该消息是否已经使用过，防止重复提交
        require(!executed[messageHash], "Message already executed");

        // 3. 将哈希转换为以太坊签名标准格式 ("\x19Ethereum Signed Message:\n32" + hash)
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // 4. 从签名中恢复出签名者的地址
        address signer = ethSignedMessageHash.recover(signature);

        // 5. 验证恢复出的地址是否为预期的地址
        require(signer == expectedSigner, "Invalid signature");
        require(signer != address(0), "Invalid signer address");

        // 6. 标记为已执行并触发事件
        executed[messageHash] = true;
        
        emit MessageVerified(signer, message);
    }

    /**
     * @dev 辅助函数：手动拆解签名（如果不使用 OpenZeppelin 库时的底层写法）
     */
    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}