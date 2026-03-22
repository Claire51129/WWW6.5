// SPDX-License-Identifier: MIT
// 许可证声明：允许自由使用、修改这个合约
pragma solidity ^0.8.0;
// 指定Solidity编译器版本：0.8.0及以上


contract GoldVault {
    // 账本：记录每个用户地址存了多少ETH（黄金）
    mapping(address => uint256) public goldBalance;
    
    // 重入锁状态（金库安全锁）
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1; // 锁：未锁住（正常使用）
    uint256 private constant _ENTERED = 2;     // 锁：已锁住（正在取钱）

    event Deposit(address indexed user, uint256 amount); // 有人存钱
    event Withdrawal(address indexed user, uint256 amount); // 有人取钱
    event AttackAttempt(address indexed attacker, string reason); // 有人尝试攻击

    constructor() {
        // 金库刚创建时，安全锁默认「未锁住」
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // 检查：如果锁是「已锁住」，拒绝操作（防止重复取钱）
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED; // 操作前锁住金库
        _; // 执行后续的取钱函数
        _status = _NOT_ENTERED; // 操作完成后解锁金库
    }

    function deposit() external payable {
        // 检查：不能存0个ETH
        require(msg.value > 0, "Must deposit something");
        
        // 账本更新：给存钱的用户加余额
        goldBalance[msg.sender] += msg.value;
        
        // 发公告：谁存了多少钱
        emit Deposit(msg.sender, msg.value);
    }

    function vulnerableWithdraw() external {
        // 步骤1：查用户账本余额
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw"); // 没钱不能取

        // 步骤2：先给用户转钱（危险！转钱时账本还没清零）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed"); // 转钱失败则提示

        // 步骤3：转完钱才清零账本（小偷可趁间隙重复取钱）
        goldBalance[msg.sender] = 0;
        
        // 发公告：谁取了多少钱
        emit Withdrawal(msg.sender, amount);
    }

    function safeWithdraw() external {
        // 步骤1：检查（查余额）
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // 步骤2：效果（先清零账本，关键！）
        goldBalance[msg.sender] = 0;

        // 步骤3：交互（后转钱，此时账本已清零，小偷无法重复取）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // 发公告：谁取了多少钱
        emit Withdrawal(msg.sender, amount);
    }

    function guardedWithdraw() external nonReentrant {
        // 步骤1：检查（查余额）
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // 步骤2：效果（先清零账本）
        goldBalance[msg.sender] = 0;

        // 步骤3：交互（后转钱）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // 发公告：谁取了多少钱
        emit Withdrawal(msg.sender, amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address user) external view returns (uint256) {
        return goldBalance[user];
    }
}