// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0; 

/**
 * @title SimpleLending
 * @dev 一个基础的 DeFi 借贷平台
 */
contract SimpleLending {

    // 存款余额（用户地址 => 存入的 ETH 数量）
    mapping(address => uint256) public depositBalances;

    // 借款余额（用户地址 => 当前欠款）
    mapping(address => uint256) public borrowBalances;

    // 抵押资产（用户地址 => 抵押的 ETH）
    mapping(address => uint256) public collateralBalances;

    // 利率（单位：基点，1% = 100）
    // 500 = 5%
    uint256 public interestRateBasisPoints = 500;

    // 抵押率（单位：基点）
    // 7500 = 75%（最多借抵押物的75%）
    uint256 public collateralFactorBasisPoints = 7500;

    // 上次计算利息的时间戳（用于计算利息增长）
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // ===== 事件（用于前端监听） =====
    event Deposit(address indexed user, uint256 amount); // 存款事件
    event Withdraw(address indexed user, uint256 amount); // 提款事件
    event Borrow(address indexed user, uint256 amount); // 借款事件
    event Repay(address indexed user, uint256 amount); // 还款事件
    event CollateralDeposited(address indexed user, uint256 amount); // 抵押存入
    event CollateralWithdrawn(address indexed user, uint256 amount); // 抵押取出

    // ===== 存款函数 =====
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount"); // 必须存入大于0的金额

        depositBalances[msg.sender] += msg.value; // 更新用户存款余额

        emit Deposit(msg.sender, msg.value); // 触发存款事件
    }

    // ===== 提款函数 =====
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount"); // 提款金额必须大于0
        require(depositBalances[msg.sender] >= amount, "Insufficient balance"); // 检查余额是否足够

        depositBalances[msg.sender] -= amount; // 扣除余额

        payable(msg.sender).transfer(amount); // 向用户转账 ETH

        emit Withdraw(msg.sender, amount); // 触发提款事件
    }

    // ===== 存入抵押物 =====
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral"); // 必须大于0

        collateralBalances[msg.sender] += msg.value; // 更新抵押余额

        emit CollateralDeposited(msg.sender, msg.value); // 触发事件
    }

    // ===== 提取抵押物 =====
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount"); // 金额检查
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral"); // 抵押是否足够

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender); // 当前债务（含利息）

        // 计算需要维持的最小抵押
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio" // 防止抵押率不足
        );

        collateralBalances[msg.sender] -= amount; // 扣除抵押

        payable(msg.sender).transfer(amount); // 转账给用户

        emit CollateralWithdrawn(msg.sender, amount); // 触发事件
    }

    // ===== 借款 =====
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount"); // 借款必须大于0
        require(address(this).balance >= amount, "Not enough liquidity in the pool"); // 合约余额是否够借

        // 最大可借金额 = 抵押 * 抵押率
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;

        uint256 currentDebt = calculateInterestAccrued(msg.sender); // 当前债务（含利息）

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount"); // 不能超借

        borrowBalances[msg.sender] = currentDebt + amount; // 更新债务

        lastInterestAccrualTimestamp[msg.sender] = block.timestamp; // 更新计息时间

        payable(msg.sender).transfer(amount); // 转账给借款人

        emit Borrow(msg.sender, amount); // 触发事件
    }

    // ===== 还款 =====
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount"); // 必须还钱

        uint256 currentDebt = calculateInterestAccrued(msg.sender); // 当前债务

        require(currentDebt > 0, "No debt to repay"); // 必须有债

        uint256 amountToRepay = msg.value; // 实际还款金额

        // 如果多还了，退回多余的钱
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;

            payable(msg.sender).transfer(msg.value - currentDebt); // 多余退回
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay; // 更新债务

        lastInterestAccrualTimestamp[msg.sender] = block.timestamp; // 更新时间

        emit Repay(msg.sender, amountToRepay); // 触发事件
    }

    // ===== 计算利息 =====
    function calculateInterestAccrued(address user) public view returns (uint256) {

        if (borrowBalances[user] == 0) {
            return 0; // 没借钱就没有利息
        }

        // 时间差
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];

        // 利息计算（线性）
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) 
                            / (10000 * 365 days);

        return borrowBalances[user] + interest; // 返回总债务（本金+利息）
    }

    // ===== 查询最大可借 =====
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    // ===== 查询池子总资金 =====
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance; // 合约里的 ETH 总量
    }
}
