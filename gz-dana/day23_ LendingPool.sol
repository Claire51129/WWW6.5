// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ============ 内置 OpenZeppelin 依赖 ============

/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 * Referenced from OpenZeppelin Contracts v4.4.1
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// ============ 主合约 ============

/**
 * @title SimpleLending
 * @notice 简化版 DeFi 借贷协议
 * 核心功能：存款、借款、还款、清算
 */
contract SimpleLending is ReentrancyGuard {
    // ============ 数据结构 ============
    struct UserAccount {
        uint256 deposited;    // 用户存入的抵押品数量
        uint256 borrowed;     // 用户借出的资产数量
        uint256 borrowTime;   // 借款时间（用于计算利息）
    }

    struct AssetPool {
        IERC20 token;              // 资产合约地址
        uint256 totalDeposited;    // 总存款量
        uint256 totalBorrowed;     // 总借款量
        uint256 borrowRate;        // 借款利率（年化，基点 10000 = 100%）
        uint256 collateralFactor;  // 抵押率（最大可借比例，如 7500 = 75%）
        bool isActive;             // 是否激活
    }

    // ============ 状态变量 ============
    mapping(string => AssetPool) public pools;
    string[] public poolSymbols;
    mapping(address => mapping(string => UserAccount)) public accounts;
    mapping(string => uint256) public assetPrices;

    uint256 public constant LIQUIDATION_THRESHOLD = 8000;
    uint256 public constant LIQUIDATION_BONUS = 500;
    uint256 public constant RATE_PRECISION = 10000;

    // ============ 事件 ============
    event Deposit(address indexed user, string symbol, uint256 amount);
    event Withdraw(address indexed user, string symbol, uint256 amount);
    event Borrow(address indexed user, string symbol, uint256 amount);
    event Repay(address indexed user, string symbol, uint256 amount);
    event Liquidate(
        address indexed liquidator,
        address indexed borrower,
        string symbol,
        uint256 repayAmount,
        uint256 seizeAmount
    );

    // ============ 修饰器 ============
    modifier poolExists(string memory symbol) {
        require(pools[symbol].isActive, "Pool not exist");
        _;
    }

    // ============ 管理员功能 ============
    function addPool(
        string memory symbol,
        address token,
        uint256 borrowRate,
        uint256 collateralFactor
    ) external {
        require(!pools[symbol].isActive, "Pool already exists");
        require(collateralFactor <= 8000, "Collateral factor too high");
        pools[symbol] = AssetPool({
            token: IERC20(token),
            totalDeposited: 0,
            totalBorrowed: 0,
            borrowRate: borrowRate,
            collateralFactor: collateralFactor,
            isActive: true
        });
        poolSymbols.push(symbol);
    }

    function updatePrice(string memory symbol, uint256 price) external {
        assetPrices[symbol] = price;
    }

    // ============ 核心功能 ============
    function deposit(string memory symbol, uint256 amount) external nonReentrant poolExists(symbol) {
        require(amount > 0, "Amount must be > 0");
        AssetPool storage pool = pools[symbol];
        UserAccount storage account = accounts[msg.sender][symbol];
        require(pool.token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        account.deposited += amount;
        pool.totalDeposited += amount;
        emit Deposit(msg.sender, symbol, amount);
    }

    function withdraw(string memory symbol, uint256 amount) external nonReentrant poolExists(symbol) {
        UserAccount storage account = accounts[msg.sender][symbol];
        AssetPool storage pool = pools[symbol];
        require(amount > 0, "Amount must be > 0");
        require(account.deposited >= amount, "Insufficient deposit");
        account.deposited -= amount;
        require(!isLiquidatable(msg.sender), "Withdraw would liquidate");
        pool.totalDeposited -= amount;
        require(pool.token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdraw(msg.sender, symbol, amount);
    }

    function borrow(string memory symbol, uint256 amount) external nonReentrant poolExists(symbol) {
        require(amount > 0, "Amount must be > 0");
        AssetPool storage pool = pools[symbol];
        UserAccount storage account = accounts[msg.sender][symbol];
        uint256 maxBorrow = getMaxBorrowAmount(msg.sender, symbol);
        uint256 newBorrow = account.borrowed + getInterest(msg.sender, symbol) + amount;
        require(newBorrow <= maxBorrow, "Insufficient collateral");
        require(newBorrow <= pool.totalDeposited - pool.totalBorrowed, "Insufficient liquidity");
        if (account.borrowed == 0) {
            account.borrowTime = block.timestamp;
        } else {
            account.borrowed = newBorrow - amount;
            account.borrowTime = block.timestamp;
        }
        account.borrowed += amount;
        pool.totalBorrowed += amount;
        require(pool.token.transfer(msg.sender, amount), "Transfer failed");
        emit Borrow(msg.sender, symbol, amount);
    }

    function repay(string memory symbol, uint256 amount) external nonReentrant poolExists(symbol) {
        UserAccount storage account = accounts[msg.sender][symbol];
        AssetPool storage pool = pools[symbol];
        uint256 totalDebt = account.borrowed + getInterest(msg.sender, symbol);
        require(totalDebt > 0, "No debt to repay");
        if (amount > totalDebt) {
            amount = totalDebt;
        }
        require(pool.token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        account.borrowed = totalDebt - amount;
        account.borrowTime = block.timestamp;
        pool.totalBorrowed -= amount;
        emit Repay(msg.sender, symbol, amount);
    }

    function liquidate(address borrower, string memory symbol, uint256 repayAmount) external nonReentrant poolExists(symbol) {
        require(isLiquidatable(borrower), "Borrower not liquidatable");
        AssetPool storage pool = pools[symbol];
        UserAccount storage account = accounts[borrower][symbol];
        uint256 totalDebt = account.borrowed + getInterest(borrower, symbol);
        require(repayAmount <= totalDebt, "Repay amount exceeds debt");
        uint256 seizeAmount = (repayAmount * (RATE_PRECISION + LIQUIDATION_BONUS)) / RATE_PRECISION;
        require(seizeAmount <= account.deposited, "Seize amount exceeds collateral");
        require(pool.token.transferFrom(msg.sender, address(this), repayAmount), "Repay transfer failed");
        account.borrowed = totalDebt - repayAmount;
        account.borrowTime = block.timestamp;
        account.deposited -= seizeAmount;
        pool.totalBorrowed -= repayAmount;
        pool.totalDeposited -= seizeAmount;
        require(pool.token.transfer(msg.sender, seizeAmount), "Seize transfer failed");
        emit Liquidate(msg.sender, borrower, symbol, repayAmount, seizeAmount);
    }

    // ============ 查询函数 ============
    function getInterest(address user, string memory symbol) public view returns (uint256) {
        UserAccount memory account = accounts[user][symbol];
        if (account.borrowed == 0 || account.borrowTime == 0) {
            return 0;
        }
        uint256 timeElapsed = block.timestamp - account.borrowTime;
        uint256 interest = (account.borrowed * pools[symbol].borrowRate * timeElapsed) / (365 days) / RATE_PRECISION;
        return interest;
    }

    function getMaxBorrowAmount(address user, string memory symbol) public view returns (uint256) {
        UserAccount memory account = accounts[user][symbol];
        AssetPool memory pool = pools[symbol];
        uint256 collateralValue = account.deposited * pool.collateralFactor / RATE_PRECISION;
        return collateralValue;
    }

    function isLiquidatable(address user) public view returns (bool) {
        for (uint i = 0; i < poolSymbols.length; i++) {
            string memory symbol = poolSymbols[i];
            UserAccount memory account = accounts[user][symbol];
            if (account.borrowed == 0) continue;
            uint256 totalDebt = account.borrowed + getInterest(user, symbol);
            uint256 collateralValue = account.deposited;
            if (totalDebt * RATE_PRECISION > collateralValue * LIQUIDATION_THRESHOLD) {
                return true;
            }
        }
        return false;
    }

    function getHealthFactor(address user) external view returns (uint256) {
        uint256 totalCollateral = 0;
        uint256 totalDebt = 0;
        for (uint i = 0; i < poolSymbols.length; i++) {
            string memory symbol = poolSymbols[i];
            UserAccount memory account = accounts[user][symbol];
            totalCollateral += account.deposited * pools[symbol].collateralFactor / RATE_PRECISION;
            totalDebt += account.borrowed + getInterest(user, symbol);
        }
        if (totalDebt == 0) return type(uint256).max;
        return (totalCollateral * 1e18) / totalDebt;
    }

    function getPoolCount() external view returns (uint256) {
        return poolSymbols.length;
    }
}