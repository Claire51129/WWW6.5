// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending (简易借贷平台)
 * @dev 一个基础的 DeFi 借贷模型，包含存款、抵押、借款和线性计息功能。
 */
contract SimpleLending {
    
    // 用户在平台里的纯存款（仅作为流动性，不作为抵押品）
    mapping(address => uint256) public depositBalances;

    // 用户的借款本息总额（欠银行的钱）
    mapping(address => uint256) public borrowBalances;

    // 用户的抵押品余额（锁在平台里证明你有钱还的保证金）
    mapping(address => uint256) public collateralBalances;

    // --- 参数设置 (使用基点 Basis Points, 10000 = 100%) ---
    
    // 年利率：500 基点 = 5%
    uint256 public interestRateBasisPoints = 500;

    // 抵押因子：7500 = 75% (意味着存 100 块抵押品，最多借 75 块)
    uint256 public collateralFactorBasisPoints = 7500;

    // 记录用户上次操作的时间戳，用来计算这段时间内产生了多少利息
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // --- 事件通知 (用于网页前端监听数据变化) ---
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    /**
     * @notice 普通存款：把钱存入池子提供流动性
     */
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice 提取存款
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    /**
     * @notice 存入抵押品：只有存了抵押品，下面才能借钱
     */
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @notice 取回抵押品
     * @dev 重要安全检查：取回后，剩下的抵押品必须还能盖住你的债务
     */
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 1. 计算当前欠债（含利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        // 2. 计算这些债务最少需要多少抵押品 (债务 / 0.75)
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        // 3. 检查：现在的抵押品 - 准备取走的 >= 必须留下的
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    /**
     * @notice 借款
     */
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 计算最大可借额度 (抵押品 * 75%)
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        // 计算当前债务
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        // 更新债务并重置时间戳（开始计算新一段利息）
        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

    /**
     * @notice 还钱
     * @dev 如果你给多了，合约会自动把多余的钱退给你
     */
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            // 退还多给的部分
            payable(msg.sender).transfer(msg.value - currentDebt);
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    /**
     * @notice 核心数学逻辑：计算随着时间产生的利息
     * @dev 利息 = 本金 * 利率 * 时间 / (100% * 365天)
     */
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0;
        }

        // 计算距离上次操作过了多久
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        // 计算利息额
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    /**
     * @notice 查询总流动性
     */
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}