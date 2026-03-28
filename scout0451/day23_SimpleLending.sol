// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//合约标题、给开发者看的功能说明
/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */

contract SimpleLending {
    // Token balances for each user用户存入借贷池的 ETH 数量
    mapping(address => uint256) public depositBalances;

    // Borrowed amounts for each user用户从池中借的ETH 数量
    mapping(address => uint256) public borrowBalances;

    // Collateral provided by each user用户提供的作为抵押的 ETH 数量
    mapping(address => uint256) public collateralBalances;

    // Interest rate in basis points (1/100 of a percent)借款人每年需支付的贷款利率
    // 500 basis points = 5% interest 基点
    uint256 public interestRateBasisPoints = 500;

    // Collateral factor in basis points (e.g., 7500 = 75%)用户只能借入他们作为抵押锁定 ETH 的 75%
    // Determines how much you can borrow against your collateral根据抵押品价值可以借多少
    uint256 public collateralFactorBasisPoints = 7500;

    // Timestamp of last interest accrual时间戳收据：上次检查时用户欠款 X，根据经过的时间来更新
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // Events存、取、借、还、抵押、提取抵押
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount); //对可支付地址调用 .transfer() 
        emit Withdraw(msg.sender, amount);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        //计算他们需要多少抵押品才能保持安全
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        //当前债务
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            payable(msg.sender).transfer(msg.value - currentDebt);
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;//重置利息累积的计时器

        emit Repay(msg.sender, amountToRepay);
    }

    //按需计算利息
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0;
        }

        //距离上次为该用户计算利息过去的时间
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    //抵押最大可借金额
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    //该合约（借贷池）持有多少 ETH
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}

