// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventEntry {
    address public admin;
    mapping(bytes32 => bool) public signatureUsed; // 你的“防重放”标记

    constructor() {
        admin = msg.sender;
    }

    // 1. 生成消息哈希（信封）
    function getMessageHash(address _attendee, uint256 _ticketId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_attendee, _ticketId));
    }

    // 2. 签到功能（验证笔迹 + 检查重放）
    function checkIn(uint256 _ticketId, bytes memory _signature) public {
        bytes32 messageHash = getMessageHash(msg.sender, _ticketId);
        bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        // 【安全检查 1】：检查签名是否被用过（你的答案！）
        require(!signatureUsed[ethSignedHash], "This ticket has already been used!");

        // 【安全检查 2】：验证签名是否来自管理员
        address signer = recoverSigner(ethSignedHash, _signature);
        require(signer == admin, "Invalid signature, not invited by admin.");

        // 【执行操作】：标记签名已作废，并完成签到
        signatureUsed[ethSignedHash] = true;
        
        // 此处可以触发 Event 或者 修改用户的签到状态
    }

    // 辅助工具：恢复签名者（职业开发者通常直接复制这段模板）
    function recoverSigner(bytes32 _hash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_hash, v, r, s);
    }

    function splitSignature(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invalid signature");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}
