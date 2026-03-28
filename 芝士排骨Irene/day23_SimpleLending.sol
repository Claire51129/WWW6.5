// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 简易借贷合约
contract SimpleLending {

    // 存款余额：记录每个用户存了多少 ETH（作为流动性供其他人借）
    mapping(address => uint256) public depositBalances;

    // 借款余额：记录每个用户借了多少 ETH（不含利息的本金记录）
    mapping(address => uint256) public borrowBalances;

    // 抵押物余额：记录每个用户锁了多少 ETH 作为抵押
    // 借钱必须先抵押，抵押物价值必须大于借款金额（超额抵押）
    mapping(address => uint256) public collateralBalances;

    // 年利率，单位是基点（basis points）
    uint256 public interestRateBasisPoints = 500;

    // 抵押率，单位也是基点
    // 7500 基点 = 75%，意思是抵押 100 ETH 最多能借 75 ETH
    // 为什么不能借满 100%？留 25% 的缓冲防止价格波动导致资不抵债
    uint256 public collateralFactorBasisPoints = 7500;

    // 上次利息计算的时间戳 - 用于按时间累计利息
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // 事件
    event Deposit(address indexed user, uint256 amount);              // 存款
    event Withdraw(address indexed user, uint256 amount);             // 取款
    event Borrow(address indexed user, uint256 amount);               // 借款
    event Repay(address indexed user, uint256 amount);                // 还款
    event CollateralDeposited(address indexed user, uint256 amount);  // 存入抵押物
    event CollateralWithdrawn(address indexed user, uint256 amount);  // 取回抵押物

    // 存款 - 用户存入 ETH 作为借贷池的流动性
    // 类比：把钱存进银行，供其他人贷款
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 取款 - 存款人取回自己存的 ETH
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    // 存入抵押物 - 借款前必须先锁定抵押物
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // 取回抵押物 - 还完债后可以取回，但必须保证剩余抵押物够覆盖未还的债务
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 计算当前总债务（本金 + 利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);

        // 计算当前债务需要多少抵押物
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        // 取回后剩余的抵押物必须 >= 需要的抵押物，否则拒绝
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // 借款 - 凭抵押物借出 ETH
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        // 借贷池里必须有足够的流动性（其他人存进来的 ETH）
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 计算最大可借金额 = 抵押物 * 抵押率
        // 例如：抵押了 100 ETH，抵押率 75% → 最多借 75 ETH
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;

        // 计算当前已有的债务（包含累计利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        // 已有债务 + 新借金额不能超过最大可借额度
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        // 更新债务余额（已有债务 + 新借金额）
        borrowBalances[msg.sender] = currentDebt + amount;
        // 重置利息计算起点为当前时间
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // 把 ETH 转给借款人
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Borrow(msg.sender, amount);
    }

    // 还款 - 借款人归还 ETH（本金 + 利息）
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        // 计算当前总债务（本金 + 利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;

        // 如果还的钱比欠的多，只扣欠款部分，多余的退回去
     
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            (bool success, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(success, "Transfer failed");// 退还多付的
        }

        // 更新债务余额
        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        // 重置利息计算起点
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    // 计算某用户当前的总债务（本金 + 累计利息）
    // 利息按时间线性增长，每秒都在涨
    function calculateInterestAccrued(address user) public view returns (uint256) {
        // 没有借款就没有利息
        if (borrowBalances[user] == 0) {
            return 0;
        }

        // 距离上次计息过了多少秒
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];

        // 利息计算公式：本金 * 年利率 * 经过的时间 / (10000 * 一年的秒数)
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    // 查询某用户最多能借多少（基于其抵押物）
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    // 查询借贷池当前总流动性（合约里所有 ETH）
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}