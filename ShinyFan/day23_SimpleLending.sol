// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */
contract SimpleLending {
    // 存入借贷池的 ETH 数量
    mapping(address => uint256) public depositBalances;

    // 贷款账本
    mapping(address => uint256) public borrowBalances;

    // 每个用户提供的作为抵押的 ETH 数量
    mapping(address => uint256) public collateralBalances;

    // 年利率是5%
    // 500 basis points = 5% 利息
    uint256 public interestRateBasisPoints = 500;

    // 决定了根据抵押品价值可以借多少
    // 只能借抵押物的75%的价值ETH
    uint256 public collateralFactorBasisPoints = 7500;

    // 上次计算利息的时间
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // 事件
    event Deposit(address indexed user, uint256 amount);//存钱
    event Withdraw(address indexed user, uint256 amount);//取钱
    event Borrow(address indexed user, uint256 amount);//借钱
    event Repay(address indexed user, uint256 amount);//还款
    event CollateralDeposited(address indexed user, uint256 amount);//存入抵押物
    event CollateralWithdrawn(address indexed user, uint256 amount);//去除抵押物

    //存钱函数
    function deposit() external payable {//payable = 这个函数可以接收 ETH
        require(msg.value > 0, "Must deposit a positive amount");//存入的钱必须要大于0
        depositBalances[msg.sender] += msg.value;//用户余额增加这次存入的金额
        emit Deposit(msg.sender, msg.value);//发送存钱事件
    }

    //取钱函数
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");//用户余额要大于取出金额
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);//谁.做什么
        emit Withdraw(msg.sender, amount);//发送取钱事件
    }

    //存入抵押物金额
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    //取出抵押物金额
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);//检查借了多少钱
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    //借钱
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

    //还款
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
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    
    //借款核心：利息计算
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        //利息计算公式
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;//返回总债务
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}
