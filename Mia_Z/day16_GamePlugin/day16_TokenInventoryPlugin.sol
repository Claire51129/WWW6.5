// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * TokenInventoryPlugin (ERC-20)
 *
 * 用于演示「插件合约再去调用标准 Token 合约」的模式。
 * 这里做一个最小可用版：
 * - 在构造函数中指定要追踪的 ERC-20 token 地址；
 * - 用户调用 updateMyBalance() 时，内部调用 IERC20(token).balanceOf(msg.sender)
 *   并把结果记录下来；
 * - 前端可以通过 view 函数读取最近一次记录到的余额。
 *
 * 注意：
 * - 这里为了保持接口简单，暂不通过 PluginStore 代理调用，
 *   而是直接由前端与本插件交互。
 */

interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract TokenInventoryPlugin {
    address public immutable token;

    // user => last recorded balance
    mapping(address => uint256) public lastRecordedBalance;

    constructor(address _token) {
        token = _token;
    }

    /**
     * 查询并记录 msg.sender 在该 ERC-20 中的余额
     */
    function updateMyBalance() external {
        uint256 bal = IERC20Minimal(token).balanceOf(msg.sender);
        lastRecordedBalance[msg.sender] = bal;
    }

    /**
     * 以字符串形式返回最近一次记录的余额
     * 方便前端直接展示，也可以结合 decimals 做人类可读格式。
     */
    function getRecordedBalanceString(
        address user
    ) external view returns (string memory) {
        uint256 bal = lastRecordedBalance[user];
        return _uintToString(bal);
    }

    /**
     * 返回 Token 的 decimals，便于前端把整数余额转成人类可读格式
     */
    function tokenDecimals() external view returns (uint8) {
        return IERC20Minimal(token).decimals();
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

