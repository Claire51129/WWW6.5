// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 金库合约 - 重入攻击与防御
contract GoldVault {

    // 用户地址 => 存款余额
    mapping(address => uint256) public goldBalance;

    // 重入锁状态变量
    // 用 uint256 而不是 bool，因为 uint256 改值比 bool 更省 gas（EVM 层面的优化）
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;  // 未进入状态
    uint256 private constant _ENTERED = 2;      // 已进入状态

    // 事件
    event Deposit(address indexed user, uint256 amount);           // 存款
    event Withdrawal(address indexed user, uint256 amount);        // 取款
    event AttackAttempt(address indexed attacker, string reason);   // 攻击尝试

    // 构造函数 - 初始化锁状态为"未进入"
    constructor() {
        _status = _NOT_ENTERED;
    }

    // 重入锁修饰符 - 防止函数被递归调用
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked"); // 如果已经在执行中，拒绝
        _status = _ENTERED;      // 标记为"执行中"
        _;                        // 执行被修饰的函数体
        _status = _NOT_ENTERED;  // 执行完毕，恢复为"未进入"
    }

    // 存款函数 - 任何人都能存 ETH
    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");
        goldBalance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 有漏洞的提取函数 - 存在重入攻击风险
    // 问题出在：先转账，后更新余额
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // 危险！先把钱转出去
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        goldBalance[msg.sender] = 0;  // 这行来得太晚了！攻击者已经反复取钱了
        emit Withdrawal(msg.sender, amount);
    }

    // 安全的提取函数 - 使用"检查-效果-交互"模式（CEI Pattern）
    // Checks-Effects-Interactions：先检查条件 → 再修改状态 → 最后做外部调用
    function safeWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");  // 检查（Checks）

        goldBalance[msg.sender] = 0;  // 效果（Effects）：先把余额清零

        // 交互（Interactions）：最后才转账
        // 即使恶意合约在 receive() 里再次调用 safeWithdraw
        // goldBalance 已经是 0 了，require(amount > 0) 通不过，攻击失败
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    // 使用重入锁的提取函数 - 双重保险
    function guardedWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");

        goldBalance[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    // 查询合约总余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 查询用户余额
    function getUserBalance(address user) external view returns (uint256) {
        return goldBalance[user];
    }
}