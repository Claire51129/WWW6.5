// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    
    // 记录每个地址存了多少金币（ETH）
    mapping(address => uint256) public goldBalance;

    // 重入锁的状态变量
    // 用uint256而不是bool，因为更省gas！
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;  // 没有在执行 = 1
    uint256 private constant _ENTERED = 2;       // 正在执行中 = 2

    // 部署时设置初始状态为"没有在执行"
    constructor() {
        _status = _NOT_ENTERED;
    }

    // 重入锁modifier
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        // 检查：如果已经在执行中，拒绝！

        _status = _ENTERED;  // 标记：正在执行
        _;                   // 执行函数内容
        _status = _NOT_ENTERED;  // 执行完毕，解锁
    }

    // 存款函数
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;  // 增加余额
    }

    // ❌ 有漏洞的取款函数
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // 问题：先转账，后更新余额
        // 黑客可以在余额更新前反复调用！
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;  // ← 太晚了！黑客已经取走很多次了
    }

    // ✅ 安全的取款函数
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;  // 先更新余额！

        // 然后才转账
        // 就算黑客想重入，余额已经是0了
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}
