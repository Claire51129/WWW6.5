// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev 基础借贷平台
 */
contract SimpleLending {

    // ================= 状态变量 =================

    // 用户存款余额
    mapping(address => uint256) public depositBalances;

    // 用户借款余额
    mapping(address => uint256) public borrowBalances;

    // 用户抵押余额
    mapping(address => uint256) public collateralBalances;

    // 利率（500 = 5%）
    uint256 public interestRateBasisPoints = 500;

    // 抵押率（7500 = 75%）
    uint256 public collateralFactorBasisPoints = 7500;

    // 上次计息时间
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // ================= 事件 =================

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    // ================= 存款 =================

    function deposit() external payable {
        // 金额必须大于0
        require(msg.value > 0, "Amount must be greater than 0");

        depositBalances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    // ================= 取款 =================

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");

        // 先更新状态
        depositBalances[msg.sender] -= amount;

        // 使用 transfer
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    // ================= 抵押 =================

    function depositCollateral() external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        collateralBalances[msg.sender] += msg.value;

        emit CollateralDeposited(msg.sender, msg.value);
    }

    // ================= 提取抵押 =================

    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 当前债务（含利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);

        // 最低抵押要求
        uint256 requiredCollateral =
            (borrowedAmount * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Collateral ratio too low"
        );

        collateralBalances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ================= 借款 =================

    function borrow(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient liquidity");

        uint256 maxBorrowAmount =
            (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;

        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds borrow limit");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);

        emit Borrow(msg.sender, amount);
    }

    // ================= 还款 =================

    function repay() external payable {
        require(msg.value > 0, "Amount must be greater than 0");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt");

        uint256 amountToRepay = msg.value;

        // 多还处理
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;

            // 退回多余ETH
            payable(msg.sender).transfer(msg.value - currentDebt);
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    // ================= 利息计算 =================

    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0;
        }

        uint256 timeElapsed =
            block.timestamp - lastInterestAccrualTimestamp[user];

        uint256 interest =
            (borrowBalances[user] *
                interestRateBasisPoints *
                timeElapsed) /
            (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    // ================= 查询 =================

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}