// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingPool {
    // 用户存款余额 - 流动性提供者的资金
    mapping(address => uint256) public depositBalances;

    // 用户借款余额 - 借款人欠款
    mapping(address => uint256) public borrowBalances;

    // 用户抵押品余额 - 借款的担保
    mapping(address => uint256) public collateralBalances;

    // 年化利率: 500基点 = 5%
    uint256 public interestRateBasisPoints = 500;

    // 抵押因子: 7500基点 = 75%
    uint256 public collateralFactorBasisPoints = 7500;

    // 上次计息时间戳
    uint256 public lastInterestAccrualTimestamp;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event InterestAccrued(address indexed user, uint256 interestAmount);

    constructor() {
        lastInterestAccrualTimestamp = block.timestamp;
    }

    // 存款
    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");

        depositBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // 提款
    function withdraw(uint256 amount) external {
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");

        // CEI: 先更新状态
        depositBalances[msg.sender] -= amount;

        // 再转账
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // 存入抵押品
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit collateral");

        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // 提取抵押品
    function withdrawCollateral(uint256 amount) external {
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 已有借款时，需要保留足够抵押
        uint256 requiredCollateral = 0;
        if (borrowBalances[msg.sender] > 0) {
            requiredCollateral =
                (borrowBalances[msg.sender] * 10000) /
                collateralFactorBasisPoints;
        }

        uint256 maxWithdraw = collateralBalances[msg.sender] - requiredCollateral;

        require(amount <= maxWithdraw, "Would under-collateralize loan");

        collateralBalances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
         require(success, "Transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // 借款
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow something");

        uint256 maxBorrow = getMaxBorrowAmount(msg.sender);
        require(amount <= maxBorrow, "Insufficient collateral");
        require(address(this).balance >= amount, "Insufficient pool liquidity");

        borrowBalances[msg.sender] += amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
         require(success, "Transfer failed");

        emit Borrowed(msg.sender, amount);
    }

    // 还款
    function repay() external payable {
        require(msg.value > 0, "Must repay something");
        require(borrowBalances[msg.sender] > 0, "No loan to repay");

        uint256 repayAmount = msg.value;

        // 如果还款金额超过欠款，退回多余部分
        if (repayAmount > borrowBalances[msg.sender]) {
            repayAmount = borrowBalances[msg.sender];
            (bool success, ) = payable(msg.sender).call{value: msg.value - repayAmount}("");
             require(success, "Refund failed");
        }

        borrowBalances[msg.sender] -= repayAmount;

        emit Repaid(msg.sender, repayAmount);
    }

    // 简化版计息：按时间线性累积到调用者借款上
    function accrueInterest() external {
        require(borrowBalances[msg.sender] > 0, "No active loan");

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp;
        require(timeElapsed > 0, "No time elapsed");

        // 利息 = 本金 * 年利率 * 时间 / (10000 * 365 days)
        uint256 interest = (borrowBalances[msg.sender] *
            interestRateBasisPoints *
            timeElapsed) / (10000 * 365 days);

        borrowBalances[msg.sender] += interest;
        lastInterestAccrualTimestamp = block.timestamp;

        emit InterestAccrued(msg.sender, interest);
    }

    // 获取用户最大可借金额（剩余可借）
    function getMaxBorrowAmount(address user) public view returns (uint256) {
        uint256 maxTotalBorrow = (collateralBalances[user] *
            collateralFactorBasisPoints) / 10000;

        if (maxTotalBorrow <= borrowBalances[user]) {
            return 0;
        }

        return maxTotalBorrow - borrowBalances[user];
    }

    // 获取总流动性
    function getTotalLiquidity() public view returns (uint256) {
        return address(this).balance;
    }

    // 查询健康因子（>10000 较安全，=10000 临界）
    function getHealthFactor(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return type(uint256).max;
        }

        uint256 adjustedCollateral = (collateralBalances[user] *
            collateralFactorBasisPoints) / 10000;

        return (adjustedCollateral * 10000) / borrowBalances[user];
    }

    // 查询用户信息
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 depositBalance,
            uint256 borrowBalance,
            uint256 collateralBalance,
            uint256 maxBorrowAmount,
            uint256 healthFactor
        )
    {
        return (
            depositBalances[user],
            borrowBalances[user],
            collateralBalances[user],
            getMaxBorrowAmount(user),
            getHealthFactor(user)
        );
    }
}