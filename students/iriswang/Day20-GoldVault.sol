// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 金库合约：用户可以存入 ETH，并从自己的余额中提取。
// 本合约展示了三种提取方式：
// 1. vulnerableWithdraw : 存在重入漏洞（先转账后更新余额）
// 2. safeWithdraw       : 使用“检查-效果-交互”模式，先更新后转账
// 3. guardedWithdraw    : 使用重入锁（nonReentrant）防止重入
contract GoldVault {
    mapping(address => uint256) public goldBalance;   // 用户余额
    
    // 重入锁状态变量
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    
    // 事件
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event AttackAttempt(address indexed attacker, string reason);
    
    constructor() {
        _status = _NOT_ENTERED;   // 初始化锁为未进入状态
    }
    
    // 重入锁修饰符：函数执行期间禁止再次进入
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    
    // 存款函数
    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");
        goldBalance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    // ========== 易受攻击的提取函数（存在重入漏洞） ==========
    // 漏洞原因：先进行外部转账（call），然后才将用户余额清零。
    // 攻击者可以在转账的 receive() 中再次调用 vulnerableWithdraw，
    // 导致余额尚未清零，从而重复提取。
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // 危险：先转账，后更新状态
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        goldBalance[msg.sender] = 0;  // 状态更新在转账之后！
        emit Withdrawal(msg.sender, amount);
    }
    
    // ========== 安全提取方式1：先更新状态，再转账 ==========
    // 遵循“检查-效果-交互”模式，在外部调用前更新状态，可防止重入。
    function safeWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        // 先更新状态（将余额清零）
        goldBalance[msg.sender] = 0;
        
        // 再进行外部转账
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    // ========== 安全提取方式2：使用重入锁 ==========
    // 通过 nonReentrant 修饰符，确保函数执行期间不能再次进入，有效防止重入。
    function guardedWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance to withdraw");
        
        goldBalance[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    // 辅助查询函数
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getUserBalance(address user) external view returns (uint256) {
        return goldBalance[user];
    }
}
