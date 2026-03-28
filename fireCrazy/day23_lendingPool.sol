// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 基础 DeFi 借贷池 (SimpleLendingPool)
 * @notice 实现存款、抵押、借款、计息功能的教学演示合约
 */
contract SimpleLendingPool {
    // --- 状态变量 ---

    mapping(address => uint256) public depositBalances;    // 用户存款余额
    mapping(address => uint256) public borrowBalances;     // 用户借款本金
    mapping(address => uint256) public collateralBalances; // 用户抵押品余额
    
    // 金融参数 (使用基点系统 BPS: 10000 = 100%)
    uint256 public interestRateBps = 500;    // 5% 年利率
    uint256 public collateralFactorBps = 7500; // 75% 抵押率 (LTV)
    uint256 public lastAccrualTime;          // 全局上次计息时间戳戳

    // --- 事件 ---
    event CollateralDeposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);

    constructor() {
        lastAccrualTime = block.timestamp;
    }

    /**
     * @dev 存入 ETH 作为抵押品
     */
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @dev 计算用户当前最大可借额度
     * 公式: (抵押品价值 * 抵押因子) - 已借本金
     */
    function getMaxBorrowAmount(address user) public view returns (uint256) {
        uint256 maxBorrow = (collateralBalances[user] * collateralFactorBps) / 10000;
        if (maxBorrow <= borrowBalances[user]) return 0;
        return maxBorrow - borrowBalances[user];
    }

    /**
     * @dev 借款逻辑
     */
    function borrow(uint256 amount) external {
        uint256 maxAvailable = getMaxBorrowAmount(msg.sender);
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= maxAvailable, "Insufficient collateral");

        // 遵循 Check-Effects-Interactions 模式
        borrowBalances[msg.sender] += amount;
        
        // 实际转账
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Borrowed(msg.sender, amount);
    }

    /**
     * @dev 计算随时间产生的利息 (简单单利模型)
     */
    function calculateInterest(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - lastAccrualTime;
        // 利息 = 本金 * 利率 * 时间 / (一年的秒数 * 10000)
        return (borrowBalances[user] * interestRateBps * timeElapsed) / (365 days * 10000);
    }

    /**
     * @dev 还款逻辑
     */
    function repay() external payable {
        require(msg.value > 0, "Must repay something");
        
        uint256 interest = calculateInterest(msg.sender);
        uint256 totalDebt = borrowBalances[msg.sender] + interest;

        uint256 repayAmount = msg.value;
        
        // 如果支付金额超过债务，退还余额
        if (repayAmount > totalDebt) {
            uint256 refund = repayAmount - totalDebt;
            repayAmount = totalDebt;
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            require(success, "Refund failed");
        }

        // 更新账本：先扣除利息（此处简化为直接减少借款余额）
        borrowBalances[msg.sender] -= (repayAmount > interest) ? (repayAmount - interest) : 0;
        
        emit Repaid(msg.sender, repayAmount);
    }

    // 允许合约接收 ETH
    receive() external payable {}
}
