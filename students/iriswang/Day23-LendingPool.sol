// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LendingPool
 * @notice 一个简单的去中心化借贷合约（基础版）
 * @dev 用户可存入ETH赚取利息，也可抵押ETH借出ETH（支付利息）
 *      每个用户只能有一笔借款（简化模型，便于理解）
 */
contract LendingPool {
    // ========== 状态变量 ==========
    // 存款余额：用户存入的ETH数量
    mapping(address => uint256) public depositBalances;
    // 借款余额：用户借出的ETH本金（尚未还款）
    mapping(address => uint256) public borrowBalances;
    // 抵押品余额：用户作为担保的ETH数量
    mapping(address => uint256) public collateralBalances;
    // 借款时间戳：记录用户开始借款的时间（用于计算利息）
    mapping(address => uint256) public borrowTimestamps;

    // 年化利率：500基点 = 5%（10000基点 = 100%）
    uint256 public constant INTEREST_RATE_BASIS_POINTS = 500;
    // 抵押因子：7500基点 = 75%（即抵押1 ETH最多可借0.75 ETH）
    uint256 public constant COLLATERAL_FACTOR_BASIS_POINTS = 7500;
    // 一年时间（秒），用于利率计算
    uint256 public constant YEAR = 365 days;

    // ========== 事件 ==========
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount, uint256 timestamp);
    event Repaid(address indexed user, uint256 amount, uint256 interest);

    // ========== 存款与提款 ==========
    /**
     * @notice 存入ETH（成为流动性提供者）
     * @dev 必须发送ETH，存入后余额增加
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");
        depositBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice 提取存款
     * @param amount 提取数量（wei）
     */
    function withdraw(uint256 amount) external {
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        // CEI模式：先更新状态，后转账，防止重入
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // ========== 抵押品管理 ==========
    /**
     * @notice 存入抵押品（ETH）
     * @dev 借款人需先存入抵押品才能借款
     */
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @notice 提取抵押品（需确保提取后抵押率仍满足要求）
     * @param amount 提取数量（wei）
     */
    function withdrawCollateral(uint256 amount) external {
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 计算在保持抵押率的情况下，最多能提取多少抵押品
        uint256 maxWithdraw = getMaxWithdrawableCollateral(msg.sender);
        require(amount <= maxWithdraw, "Would under-collateralize loan");

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ========== 借款与还款 ==========
    /**
     * @notice 借款（用户需已有抵押品）
     * @param amount 借款数量（wei）
     */
    function borrow(uint256 amount) external {
        require(amount > 0, "Borrow amount must be positive");
        // 简化：每个用户只能有一笔未还借款
        require(borrowBalances[msg.sender] == 0, "Existing loan; repay first");
        require(collateralBalances[msg.sender] > 0, "No collateral");

        uint256 maxBorrow = getMaxBorrowAmount(msg.sender);
        require(amount <= maxBorrow, "Insufficient collateral");

        // 记录借款信息
        borrowBalances[msg.sender] = amount;
        borrowTimestamps[msg.sender] = block.timestamp;

        // 转账给借款人
        payable(msg.sender).transfer(amount);
        emit Borrowed(msg.sender, amount, block.timestamp);
    }

    /**
     * @notice 还款（本金 + 利息）
     * @dev 用户发送ETH，合约自动扣除欠款（包括利息），多余部分退回
     */
    function repay() external payable {
        require(msg.value > 0, "Must repay something");
        require(borrowBalances[msg.sender] > 0, "No loan to repay");

        // 计算应付利息
        uint256 interest = calculateInterestAccrued(msg.sender);
        uint256 totalOwed = borrowBalances[msg.sender] + interest;
        require(totalOwed > 0, "No debt");

        uint256 repayAmount = msg.value;
        if (repayAmount >= totalOwed) {
            // 还清全部欠款，退回多余部分
            uint256 refund = repayAmount - totalOwed;
            if (refund > 0) {
                payable(msg.sender).transfer(refund);
            }
            // 清除借款记录
            borrowBalances[msg.sender] = 0;
            borrowTimestamps[msg.sender] = 0;
            emit Repaid(msg.sender, totalOwed, interest);
        } else {
            // 不允许部分还款（简化处理）
            revert("Please repay full amount");
        }
    }

    // ========== 查询函数 ==========
    /**
     * @notice 获取用户最大可借金额
     * @param user 用户地址
     * @return 最大可借ETH数量（wei）
     */
    function getMaxBorrowAmount(address user) public view returns (uint256) {
        // 最大借款 = 抵押品价值 × 抵押率
        return (collateralBalances[user] * COLLATERAL_FACTOR_BASIS_POINTS) / 10000;
    }

    /**
     * @notice 获取用户在不导致抵押不足的前提下，可提取的最大抵押品数量
     * @param user 用户地址
     * @return 最大可提取数量（wei）
     */
    function getMaxWithdrawableCollateral(address user) public view returns (uint256) {
        // 所需最低抵押品 = 借款金额 / 抵押率
        uint256 requiredCollateral = (borrowBalances[user] * 10000) / COLLATERAL_FACTOR_BASIS_POINTS;
        if (collateralBalances[user] > requiredCollateral) {
            return collateralBalances[user] - requiredCollateral;
        }
        return 0;
    }

    /**
     * @notice 计算用户截至当前时间应支付的利息（年化5%）
     * @param user 用户地址
     * @return 应计利息（wei）
     */
    function calculateInterestAccrued(address user) public view returns (uint256) {
        uint256 borrowAmount = borrowBalances[user];
        if (borrowAmount == 0) return 0;

        uint256 timeElapsed = block.timestamp - borrowTimestamps[user];
        // 利息 = 本金 × 年利率 × 时间占比
        // 年利率 = INTEREST_RATE_BASIS_POINTS / 10000
        return (borrowAmount * INTEREST_RATE_BASIS_POINTS * timeElapsed) / (10000 * YEAR);
    }

    /**
     * @notice 获取合约总ETH余额（存款总额 - 借出总额 + 抵押品总额）
     */
    function getTotalLiquidity() public view returns (uint256) {
        return address(this).balance;
    }

    function getDepositBalance(address user) public view returns (uint256) {
        return depositBalances[user];
    }

    function getBorrowBalance(address user) public view returns (uint256) {
        return borrowBalances[user];
    }

    function getCollateralBalance(address user) public view returns (uint256) {
        return collateralBalances[user];
    }

    // ========== 辅助函数（仅供测试） ==========
    /**
     * @notice 紧急提款，提取合约中所有ETH（仅用于测试，实际生产需权限控制）
     */
    function emergencyWithdraw() external {
        require(address(this).balance > 0, "No funds");
        payable(msg.sender).transfer(address(this).balance);
    }
}
