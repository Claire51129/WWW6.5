// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLending {
    mapping(address => uint256) public depositBalances;
    mapping(address => uint256) public borrowBalances;
    mapping(address => uint256) public collateralBalances;
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    uint256 public interestRateBasisPoints = 500;
    uint256 public collateralFactorBasisPoints = 7500;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    // ✅ 正常
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // ✅ 修复 transfer → call
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    // ✅ 正常
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // ✅ 修复 transfer → call
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ✅ 修复 利息重复计算 + transfer
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity");

        uint256 maxBorrow = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrow, "Exceeds max borrow");

        // 🔥 修复：只加新借的，不加已有债务
        borrowBalances[msg.sender] = currentDebt + amount;

        if (lastInterestAccrualTimestamp[msg.sender] == 0) {
            lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
        }

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Borrow(msg.sender, amount);
    }

    // ✅ 修复 transfer
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt");

        uint256 repayAmount = msg.value;
        if (repayAmount > currentDebt) {
            repayAmount = currentDebt;
            (bool suc, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(suc, "Refund failed");
        }

        borrowBalances[msg.sender] = currentDebt - repayAmount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, repayAmount);
    }

    // ✅ 正常
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) return 0;
        uint256 time = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * time) / (10000 * 365 days);
        return borrowBalances[user] + interest;
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}