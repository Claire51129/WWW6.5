// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

///所有transfer都改成了call

/**
 * @title SimpleLending
 * @dev 一个简单的 DeFi 借贷合约（教学版）,现实 DeFi 会更复杂
 */
contract SimpleLending {

    // ===== 存款（普通存钱）=====
    mapping(address => uint256) public depositBalances;

    // ===== 借款（用户欠的钱）=====
    mapping(address => uint256) public borrowBalances;

    // ===== 抵押（用来借钱的担保）=====
    mapping(address => uint256) public collateralBalances;

    // ===== 利率（单位：basis points）=====
    // 500 = 5%
    uint256 public interestRateBasisPoints = 500;

    // ===== 抵押率（借款比例）=====
    // 7500 = 75%
    // 意味着：最多借抵押物的 75%
    uint256 public collateralFactorBasisPoints = 7500;

    // ===== 上次计息时间 =====
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // ===== 事件（用于前端监听）=====
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    // ===== 存钱 =====
    function deposit() external payable {
        // 必须存正数
        require(msg.value > 0, "Must deposit a positive amount");

        // 增加用户存款余额
        depositBalances[msg.sender] += msg.value;

        // 触发事件
        emit Deposit(msg.sender, msg.value);
    }

    // ===== 取钱 =====
    function withdraw(uint256 amount) external {

        // 不能取 0
        require(amount > 0, "Must withdraw a positive amount");

        // 余额必须够
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");

        // 扣除余额
        depositBalances[msg.sender] -= amount;

        // 转钱给用户
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    // ===== 存抵押 =====
    function depositCollateral() external payable {

        // 必须存正数
        require(msg.value > 0, "Must deposit a positive amount as collateral");

        // 增加抵押余额
        collateralBalances[msg.sender] += msg.value;

        emit CollateralDeposited(msg.sender, msg.value);
    }

    // ===== 提取抵押 =====
    function withdrawCollateral(uint256 amount) external {

        require(amount > 0, "Must withdraw a positive amount");

        // 抵押必须够
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 当前债务（包含利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);

        // 计算最低需要的抵押
        uint256 requiredCollateral =
            (borrowedAmount * 10000) / collateralFactorBasisPoints;

        // 提取后仍必须满足抵押率
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        // 扣除抵押
        collateralBalances[msg.sender] -= amount;

        // 转回用户
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ===== 借钱 =====
    function borrow(uint256 amount) external {

        require(amount > 0, "Must borrow a positive amount");

        // 合约必须有钱（流动性）
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 最大可借金额 = 抵押 * 75%
        uint256 maxBorrowAmount =
            (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;

        // 当前债务（含利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        // 不能超过最大借款
        require(
            currentDebt + amount <= maxBorrowAmount,
            "Exceeds allowed borrow amount"
        );

        // 更新债务
        borrowBalances[msg.sender] = currentDebt + amount;

        // 更新时间戳（用于计算利息）
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // 把钱转给用户
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Borrow(msg.sender, amount);
    }

    // ===== 还钱 =====
    function repay() external payable {

        require(msg.value > 0, "Must repay a positive amount");

        // 当前债务（含利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;

        // 如果还多了，多余的钱退回
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;

            (bool success, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(success, "Transfer failed");
        }

        // 更新剩余债务
        borrowBalances[msg.sender] = currentDebt - amountToRepay;

        // 更新时间戳
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    // ===== 计算债务（含利息）=====
    function calculateInterestAccrued(address user)
        public
        view
        returns (uint256)
    {
        // 没借钱就返回 0
        if (borrowBalances[user] == 0) {
            return 0;
        }

        // 经过的时间
        uint256 timeElapsed =
            block.timestamp - lastInterestAccrualTimestamp[user];

        // 利息 = 本金 × 利率 × 时间
        uint256 interest =
            (borrowBalances[user] * interestRateBasisPoints * timeElapsed)
            / (10000 * 365 days);

        // 返回本金 + 利息
        return borrowBalances[user] + interest;
    }

    // ===== 查看最大可借金额 =====
    function getMaxBorrowAmount(address user)
        external
        view
        returns (uint256)
    {
        return
            (collateralBalances[user] * collateralFactorBasisPoints) / 10000; 
            //Solidity 不支持小数,所以除以10000
    }

    // ===== 查看池子总资金 =====
    function getTotalLiquidity()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}