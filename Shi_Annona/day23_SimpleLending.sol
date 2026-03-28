// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLending{
    // Token balances for each user
    mapping(address => uint256) public depositBalances;

    // Borrowed amounts for each user 每个账户从合约里借的钱
    mapping(address => uint256) public borrowBalances;

    // Collateral provided by each user
    //用户提供的抵押物
    mapping(address => uint256) public collateralBalances;

    // Interest rate in basis points (1/100 of a percent)
    // 500 basis points = 5% interest
    //借贷利息，为甚是500不是0.05？因为要避免使用小数和浮点数，所以用基准点作为利息单位，1基准点=0.01% = 0.0001，那么0.05就是500
    uint256 public interestRateBasisPoints = 500;

    // Collateral factor in basis points (e.g., 7500 = 75%)
    // Determines how much you can borrow against your collateral
    //抵押物价格的75%决定了能借多少带宽
    uint256 public collateralFactorBasisPoints = 7500;

    // Timestamp of last interest accrual
    //上一次借贷的时间，用于计算利息
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    //借给合约钱，合约用于放贷款
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
    //整个借贷的核心，利息计算器，只在调用的时候计算利息
    function calculateInterestAccrued(address user) public view returns (uint256) {
        //没有借款
        if (borrowBalances[user] == 0) {
            return 0;
        }
        //当前时间与上一次借钱的时间差
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        //利息=（本金×利息基准点×经过的秒数）/(10000 × 一年的秒数)
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    //增加抵押物余额
    function depositCollateral() external payable {
        //增加这个余额是付费的
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    //使用抵押物余额提取合约里的钱
    function withdrawCollateral(uint256 amount) external {
        //基本检查，输入数值检查，以及抵押物余额检查
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");
        
        //计算用户之前的借款+利息
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        //计算需要这次需要多少抵押物，如果欠了1，就需要价值1.33的抵押物
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;
        //如果扣除了这次的借款，用户的抵押物账户还是大于合约应持有抵押物，就借出，否则不借
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );
        //检查通过，借出
        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    //用户使用该函数借钱
    function borrow(uint256 amount) external {
        //检查用户输入金额
        require(amount > 0, "Must borrow a positive amount");
        //检查合约账户余额
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        //计算最大能借款的金额
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        //计算当前债务
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        //借钱不能超过最大的允许借钱金额
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");
        //记账
        borrowBalances[msg.sender] = currentDebt + amount;
        //盖上借款时间戳
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        //付款
        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }
    //用户还钱
    function repay() external payable {
        //检查用户钱包输入
        require(msg.value > 0, "Must repay a positive amount");
        //检查当前债务
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            //如果用户输入的价值大于她的债务，更新应该的还款为当前债务
            amountToRepay = currentDebt;
            //退回多余的部分
            payable(msg.sender).transfer(msg.value - currentDebt); // Refund the extra
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    //当前合约中有多少资金
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }



}