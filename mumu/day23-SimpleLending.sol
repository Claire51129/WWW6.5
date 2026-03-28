// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 * @dev 一个接单的借贷、储蓄、交易
 提供几个重要功能
- 将 ETH 存入池中
- 锁定抵押品以获取贷款
- 基于该抵押品借入 ETH
- 用利息偿还贷款
- 完成后再提取资金
 */
contract SimpleLending {
    // Token balances for each user
    // 每个用户的存入的金额 单位ETH
    mapping(address => uint256) public depositBalances;

    // Borrowed amounts for each user
    // 每个用户从合约解除的金额
    mapping(address => uint256) public borrowBalances;

    // Collateral provided by each user
    // 每个用户的抵押品
    mapping(address => uint256) public collateralBalances;

    // Interest(利息) rate in basis points (1/100 of a percent)
    // 500 basis points = 5% interest。
    // 存款/借出利息 5%
    uint256 public interestRateBasisPoints = 500;

    // Collateral factor in basis points (e.g., 7500 = 75%)
    // Determines how much you can borrow against your collateral
    // 决定了可以解除抵押物 75%价值的金额
    uint256 public collateralFactorBasisPoints = 7500;

    // Timestamp of last interest accrual
    // 用户最后利息的累积时间戳
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // Events
    // 存款
    event Deposit(address indexed user, uint256 amount);
    // 提取
    event Withdraw(address indexed user, uint256 amount);
    // 借出
    event Borrow(address indexed user, uint256 amount);
    // 偿还
    event Repay(address indexed user, uint256 amount);
    // 存抵押物
    event CollateralDeposited(address indexed user, uint256 amount);
    // 赎回抵押物事件
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
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    // 存入抵押物，锁定ETH？增加用户抵押品余额
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // 赎回抵押物
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

    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 计算用户当前的抵押物可借的资产金额
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        // 当前的欠款
        uint256 currentDebt = calculateInterestAccrued(msg.sender); 

        // 检查最大可借金额
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        // 更新用户借款金额
        borrowBalances[msg.sender] = currentDebt + amount;
        // 重新记录利息计算时间
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // 转帐给用户
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Borrow(msg.sender, amount);
    }

    // 还款
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            // 只扣除用户需要扣款的部分，剩下的退还给用户
            (bool success, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(success, "Transfer failed");
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0; 
        }

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        // 用户已借的金额*利息*已借款时间 / （10000 * 365） // 利息率是年利率
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}


/**

notice：
（1）payable 函数被调用时，ETH 的转移在函数执行前就自动完成了。
    payable 函数：接收 ETH 是自动的，不需要 transfer
（2）

DeFi：Decentralized Finance 去中心化金融
储蓄、借贷、交易 去除中介机构
常见的DeFi应用：
1. 去中心化交易所
    Uniswap、Curve
功能：直接交换代币，不需要中心化交易所

2. 借贷协议
    Aave、Compound
功能：存入资产赚利息（啊？为什么呢？）；或者抵押资产来借贷其他代币（抵押ETH借出USDT）

3. 稳定币
    DAI、USDC
功能：与美元1:1锚定的加密货币

4. 流动性挖矿｜收益聚合
    YEARN Finance
功能：自动把资金投入到收益最高的策略中
    （存入USDC，合约自动帮我们找到最高利息的借贷协议）


Deposits  存款	抵押品
你借给池子的钱 💸	你用来借钱的锁钱 💳
可以自由提取（除非用于借贷）	仅当您的贷款安全时才可归还
您可从中赚取利息（如果系统支持该功能）	它支持您的借贷并保障协议安全
 */