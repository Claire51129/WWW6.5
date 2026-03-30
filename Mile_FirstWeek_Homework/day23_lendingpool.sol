// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 基础借贷池合约
 * @dev 实现了存款、抵押、借款、还款和基于时间的利息计算
 */
contract LendingPool {
    // --- 状态变量 ---
    
    // 用户存款余额 (流动性提供者)
    mapping(address => uint256) public depositBalances;
    // 用户借款本金余额
    mapping(address => uint256) public borrowBalances;
    // 用户抵押品余额 (ETH)
    mapping(address => uint256) public collateralBalances;
    // 用户上次操作/计息的时间戳
    mapping(address => uint256) public lastUpdateTimestamp;

    // 金融参数 (使用基点 Basis Points, 10000 = 100%)
    uint256 public constant interestRateBasisPoints = 500;    // 年化 5%
    uint256 public constant collateralFactorBasisPoints = 7500; // 抵押率 75%
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // --- 事件 ---
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);

    // --- 核心功能函数 ---

    /**
     * @dev 存款：提供流动性
     */
    function deposit() external payable {
        require(msg.value > 0, "Amount must > 0");
        depositBalances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev 提取存款
     */
    function withdraw(uint256 amount) external {
        require(depositBalances[msg.sender] >= amount, "Insufficient deposit balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev 存入抵押品
     */
    function depositCollateral() external payable {
        require(msg.value > 0, "Amount must > 0");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @dev 提取抵押品：需检查剩余抵押是否足以支撑借款
     */
    function withdrawCollateral(uint256 amount) external {
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");
        
        // 计算当前借款所需的最低抵押额
        // 公式：抵押品价值 >= 借款额 / 75%  => 抵押品 * 7500 >= 借款额 * 10000
        uint256 requiredCollateral = (borrowBalances[msg.sender] * 10000) / collateralFactorBasisPoints;
        require(collateralBalances[msg.sender] - amount >= requiredCollateral, "Would under-collateralize loan");

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    /**
     * @dev 借款：基于抵押品价值执行
     */
    function borrow(uint256 amount) external {
        uint256 maxBorrow = getMaxBorrowAmount(msg.sender);
        require(amount <= maxBorrow, "Exceeds max borrow limit");
        require(address(this).balance >= amount, "Insufficient pool liquidity");

        // 借款前更新时间戳以开始计息
        if (borrowBalances[msg.sender] == 0) {
            lastUpdateTimestamp[msg.sender] = block.timestamp;
        }

        borrowBalances[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
        emit Borrowed(msg.sender, amount);
    }

    /**
     * @dev 还款：用户偿还 ETH 减少借款余额
     */
    function repay() external payable {
        require(msg.value > 0, "Must repay something");
        uint256 currentDebt = borrowBalances[msg.sender];
        require(currentDebt > 0, "No active loan");

        uint256 repayAmount = msg.value;
        if (repayAmount > currentDebt) {
            repayAmount = currentDebt;
            // 退回多余的钱
            payable(msg.sender).transfer(msg.value - repayAmount);
        }

        borrowBalances[msg.sender] -= repayAmount;
        emit Repaid(msg.sender, repayAmount);
    }

    // --- 视图/查询函数 ---

    /**
     * @dev 计算最大可借额度
     */
    function getMaxBorrowAmount(address user) public view returns (uint256) {
        uint256 collateral = collateralBalances[user];
        uint256 maxTotalBorrow = (collateral * collateralFactorBasisPoints) / 10000;
        
        if (maxTotalBorrow <= borrowBalances[user]) return 0;
        return maxTotalBorrow - borrowBalances[user];
    }

    /**
     * @dev 计算累积利息 (本金 * 利率 * 时间 / 总时间)
     */
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0 || lastUpdateTimestamp[user] == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - lastUpdateTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) 
                            / (SECONDS_PER_YEAR * 10000);
        return interest;
    }

    /**
     * @dev 获取池子总流动性
     */
    function getTotalLiquidity() public view returns (uint256) {
        return address(this).balance;
    }
}