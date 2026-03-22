// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BattleLogPlugin
 * - 用于记录玩家的战斗日志
 * - 为了与 PluginStore 的 runPlugin/runPluginView 兼容，接口尽量保持 (address,string) 风格
 *
 * 这里做一个简化版设计：
 * - 前端把一整条战斗描述（例如 "vs 0x1234... WIN"）作为字符串传入
 * - 合约内部记录最近的若干条（这里演示只返回最新一条）
 */
contract BattleLogPlugin {
    struct BattleLog {
        string summary; // 例如： "vs 0x1234... WIN"
        uint256 timestamp;
    }

    // user => battle logs
    mapping(address => BattleLog[]) private logs;

    /**
     * 新增一条战斗日志
     * 预期由 PluginStore 调用：addBattleLog(user, summary)
     */
    function addBattleLog(address user, string memory summary) public {
        logs[user].push(
            BattleLog({summary: summary, timestamp: block.timestamp})
        );
    }

    /**
     * 获取用户最近一条战斗日志
     * 返回格式化后的字符串，方便前端直接展示
     */
    function getLastBattleLog(
        address user
    ) public view returns (string memory) {
        uint256 length = logs[user].length;
        if (length == 0) {
            return "No battle log";
        }

        BattleLog memory last = logs[user][length - 1];
        // 简单拼接：summary + " @timestamp"
        return string(
            abi.encodePacked(
                last.summary,
                " @",
                _uintToString(last.timestamp)
            )
        );
    }

    // ===== 内部工具：uint 转 string =====
    function _uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint256 temp = v;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (v != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        return string(buffer);
    }
}

