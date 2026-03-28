// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract SimpleLending {
    // ==================== 状态变量：存储所有用户数据 ====================
    // 每个用户的存款余额（存进平台的ETH）
    mapping(address => uint256) public depositBalances;
    // 每个用户的借款余额（欠平台的ETH，含利息）
    mapping(address => uint256) public borrowBalances;
    // 每个用户的抵押品余额（存的抵押ETH）
    mapping(address => uint256) public collateralBalances;

    // 年利率（基点制：10000基点=100%，500基点=5%年利率）
    uint256 public interestRateBasisPoints = 500;
    // 抵押率（基点制：7500基点=75%，存100块最多借75块）
    uint256 public collateralFactorBasisPoints = 7500;

    // 每个用户上次计算利息的时间戳（用来算利息）
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // ==================== 事件：记录所有操作，链上可查 ====================
    event Deposit(address indexed user, uint256 amount);          // 用户存钱
    event Withdraw(address indexed user, uint256 amount);         // 用户取存款
    event Borrow(address indexed user, uint256 amount);           // 用户借钱
    event Repay(address indexed user, uint256 amount);           // 用户还钱
    event CollateralDeposited(address indexed user, uint256 amount); // 用户存抵押品
    event CollateralWithdrawn(address indexed user, uint256 amount); // 用户取抵押品

    // ==================== 功能1：用户存钱到平台 ====================
    function deposit() external payable {
        // 必须存大于0的钱
        require(msg.value > 0, "Must deposit a positive amount");
        // 给用户的存款余额加钱
        depositBalances[msg.sender] += msg.value;
        // 触发存钱事件
        emit Deposit(msg.sender, msg.value);
    }

    // ==================== 功能2：用户取自己的存款 ====================
    function withdraw(uint256 amount) external {
        // 必须取大于0的钱
        require(amount > 0, "Must withdraw a positive amount");
        // 存款余额必须足够
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        // 扣减用户的存款余额
        depositBalances[msg.sender] -= amount;

        // ✅ 修复：把transfer换成call，加require检查（零警告）
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw transfer failed");

        // 触发取钱事件
        emit Withdraw(msg.sender, amount);
    }

    // ==================== 功能3：用户存抵押品（为了借钱） ====================
    function depositCollateral() external payable {
        // 必须存大于0的抵押品
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        // 给用户的抵押品余额加钱
        collateralBalances[msg.sender] += msg.value;
        // 触发存抵押品事件
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // ==================== 功能4：用户取抵押品（还清钱才能取） ====================
    function withdrawCollateral(uint256 amount) external {
        // 必须取大于0的抵押品
        require(amount > 0, "Must withdraw a positive amount");
        // 抵押品余额必须足够
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 计算用户当前的欠款（含利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        // 计算需要保留的最低抵押品：欠款 × 10000 / 抵押率（保证抵押率不低于75%）
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        // 取完抵押品后，剩余抵押品必须 ≥ 最低要求，不然会爆仓
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        // 扣减用户的抵押品余额
        collateralBalances[msg.sender] -= amount;

        // ✅ 修复：把transfer换成call，加require检查（零警告）
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Collateral withdraw transfer failed");

        // 触发取抵押品事件
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ==================== 功能5：用户借钱（从平台钱池里拿） ====================
    function borrow(uint256 amount) external {
        // 必须借大于0的钱
        require(amount > 0, "Must borrow a positive amount");
        // 平台钱池（合约余额）必须足够，不然借不了
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 计算用户当前的欠款（含利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        // 计算用户最多能借多少钱：抵押品 × 抵押率 / 10000（75%）
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;

        // 借完钱后，总欠款不能超过最大可借额度
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        // 更新用户的借款余额（加上新借的钱）
        borrowBalances[msg.sender] = currentDebt + amount;
        // 更新上次计息时间（现在）
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // ✅ 修复：把transfer换成call，加require检查（零警告）
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Borrow transfer failed");

        // 触发借钱事件
        emit Borrow(msg.sender, amount);
    }

    // ==================== 功能6：用户还钱（还本金+利息） ====================
    function repay() external payable {
        // 必须还大于0的钱
        require(msg.value > 0, "Must repay a positive amount");

        // 计算用户当前的欠款（含利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        // 必须有欠款才能还
        require(currentDebt > 0, "No debt to repay");

        // 实际要还的钱：如果用户转的钱比欠款多，只还欠款（多的退回去）
        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            // ✅ 修复：把transfer换成call，加require检查（零警告）
            (bool successRefund, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(successRefund, "Refund transfer failed");
        }

        // 扣减用户的借款余额（减去还的钱）
        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        // 更新上次计息时间（现在）
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // 触发还钱事件
        emit Repay(msg.sender, amountToRepay);
    }

    // ==================== 核心功能：计算用户的累计利息 ====================
    function calculateInterestAccrued(address user) public view returns (uint256) {
        // 如果用户没欠款，利息为0
        if (borrowBalances[user] == 0) {
            return 0;
        }

        // 计算从上次计息到现在过了多少秒
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        // 计算利息：欠款 × 利率 × 时间 / (10000 × 365天)
        // 10000是基点换算，365天是年化利率转成按秒计息
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        // 返回总欠款：本金 + 利息
        return borrowBalances[user] + interest;
    }

    // ==================== 辅助功能：查询用户最多能借多少钱 ====================
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        // 最大可借 = 抵押品 × 抵押率 / 10000（75%）
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    // ==================== 辅助功能：查询平台总流动性（钱池余额） ====================
    function getTotalLiquidity() external view returns (uint256) {
        // 合约里的ETH余额就是总流动性
        return address(this).balance;
    }
}