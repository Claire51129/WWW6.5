// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLending {

    uint256 public interestRateBasisPoints = 500;
    uint256 public collateralFactorBasisPoints = 7500;
    uint256 public liquidationThresholdBps = 8000;
    uint256 public liquidationBonusBps = 500;

    mapping(address => uint256) public depositBalances;
    mapping(address => uint256) public borrowBalances;
    mapping(address => uint256) public collateralBalances;
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Liquidated(address indexed borrower, address indexed liquidator, uint256 debtRepaid, uint256 collateralSeized);

    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient deposit balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit positive collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        uint256 requiredCollateral = (currentDebt * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow positive amount");
        require(address(this).balance >= amount, "Insufficient pool liquidity");

        uint256 maxBorrow = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrow, "Exceeds allowed borrow amount");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable {
        require(msg.value > 0, "Must repay positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 toRepay = msg.value;
        if (toRepay > currentDebt) {
            payable(msg.sender).transfer(msg.value - currentDebt);
            toRepay = currentDebt;
        }

        borrowBalances[msg.sender] = currentDebt - toRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, toRepay);
    }

    function liquidate(address borrower) external payable {
        uint256 debt = calculateInterestAccrued(borrower);
        require(debt > 0, "No debt to liquidate");

        uint256 collateral = collateralBalances[borrower];
        uint256 liquidationThreshold = (collateral * liquidationThresholdBps) / 10000;

        require(debt >= liquidationThreshold, "Position is healthy, cannot liquidate");
        require(msg.value >= debt, "Must repay full debt to liquidate");

        uint256 collateralToSeize = collateral;
        uint256 bonus = (debt * liquidationBonusBps) / 10000;
        uint256 totalSeize = collateralToSeize < debt + bonus ? collateralToSeize : debt + bonus;

        borrowBalances[borrower] = 0;
        collateralBalances[borrower] = collateral - totalSeize;
        lastInterestAccrualTimestamp[borrower] = block.timestamp;

        if (msg.value > debt) {
            payable(msg.sender).transfer(msg.value - debt);
        }

        payable(msg.sender).transfer(totalSeize);

        emit Liquidated(borrower, msg.sender, debt, totalSeize);
    }

    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) return 0;

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function isLiquidatable(address user) external view returns (bool) {
        uint256 debt = calculateInterestAccrued(user);
        if (debt == 0) return false;
        uint256 threshold = (collateralBalances[user] * liquidationThresholdBps) / 10000;
        return debt >= threshold;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}
