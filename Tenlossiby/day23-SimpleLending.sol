// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev 一个基础的 DeFi 借贷平台合约
 * 功能：存款、取款、抵押、借款、还款、利息计算
 */
contract SimpleLending {
    
    // ==================== 重入锁 ====================
    // 防止重入攻击的简单机制
    // 当 _locked 为 true 时，不允许再次进入受保护的函数
    bool private _locked;
    
    // 重入锁修饰器
    // 确保函数执行期间不能被重入调用
    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }
    
    // ==================== 状态变量 ====================
    
    // 用户的存款余额
    // key: 用户地址, value: 存款金额（wei）
    mapping(address => uint256) public depositBalances;

    // 用户的借款余额（本金）
    // key: 用户地址, value: 借款金额（wei）
    mapping(address => uint256) public borrowBalances;

    // 用户的抵押品余额
    // key: 用户地址, value: 抵押品金额（wei）
    mapping(address => uint256) public collateralBalances;

    // 利率，以基点（basis points）表示
    // 1 基点 = 0.01% = 1/10000
    // 500 基点 = 5% 年利率
    uint256 public interestRateBasisPoints = 500;

    // 抵押率，以基点表示
    // 7500 基点 = 75%，表示可以借出抵押品价值的 75%
    // 例如：抵押 1 ETH，最多可以借 0.75 ETH
    uint256 public collateralFactorBasisPoints = 7500;

    // 用户上次计算利息的时间戳
    // key: 用户地址, value: 时间戳（秒）
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // ==================== 事件 ====================
    // 事件用于前端监听，记录重要操作
    
    // 存款事件
    // indexed: 可以通过用户地址筛选事件
    event Deposit(address indexed user, uint256 amount);
    
    // 取款事件
    event Withdraw(address indexed user, uint256 amount);
    
    // 借款事件
    event Borrow(address indexed user, uint256 amount);
    
    // 还款事件
    event Repay(address indexed user, uint256 amount);
    
    // 存入抵押品事件
    event CollateralDeposited(address indexed user, uint256 amount);
    
    // 取出抵押品事件
    event CollateralWithdrawn(address indexed user, uint256 amount);

    // ==================== 存款功能 ====================
    
    /**
     * @dev 存款函数 - 用户向合约存入 ETH 获取利息收益
     * payable: 允许函数接收 ETH
     */
    function deposit() external payable {
        // 检查存入金额必须大于 0
        require(msg.value > 0, "Must deposit a positive amount");
        
        // 将存入金额加到用户的存款余额中
        // msg.sender: 调用此函数的地址
        // msg.value: 随交易发送的 ETH 数量
        depositBalances[msg.sender] += msg.value;
        
        // 触发存款事件，通知前端
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 取款函数 - 用户取回存款
     * @param amount 要取出的金额（wei）
     * nonReentrant: 防止重入攻击
     */
    function withdraw(uint256 amount) external nonReentrant {
        // 检查取款金额必须大于 0
        require(amount > 0, "Must withdraw a positive amount");
        
        // 检查用户存款余额是否足够
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        
        // 先从余额中扣除（防止重入攻击）
        depositBalances[msg.sender] -= amount;
        
        // 将 ETH 转给用户
        // 使用 call{value: ...} 替代 transfer()，这是现代 Solidity 推荐的方式
        // call 更灵活，可以处理更多 gas，但需要检查返回值
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "ETH transfer failed");
        
        // 触发取款事件
        emit Withdraw(msg.sender, amount);
    }

    // ==================== 抵押品功能 ====================
    
    /**
     * @dev 存入抵押品 - 用户存入 ETH 作为借款的抵押
     * 抵押品和存款是分开的，抵押品用于担保借款
     */
    function depositCollateral() external payable {
        // 检查存入金额必须大于 0
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        
        // 增加用户的抵押品余额
        collateralBalances[msg.sender] += msg.value;
        
        // 触发抵押品存入事件
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @dev 取出抵押品 - 用户取回部分或全部抵押品
     * @param amount 要取出的抵押品金额（wei）
     * 限制：取出后必须保持足够的抵押率来覆盖借款
     * nonReentrant: 防止重入攻击
     */
    function withdrawCollateral(uint256 amount) external nonReentrant {
        // 检查取款金额必须大于 0
        require(amount > 0, "Must withdraw a positive amount");
        
        // 检查抵押品余额是否足够
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        // 计算用户当前的债务（本金 + 累积利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        
        // 计算所需的最低抵押品金额
        // 公式：所需抵押品 = 债务 / 抵押率
        // 例如：债务 0.75 ETH，抵押率 75%，则需要 1 ETH 抵押品
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

        // 检查取出后是否仍满足抵押率要求
        // 剩余抵押品必须 >= 所需抵押品
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        // 扣除抵押品余额
        collateralBalances[msg.sender] -= amount;
        
        // 将 ETH 转给用户
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "ETH transfer failed");
        
        // 触发抵押品取出事件
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ==================== 借款功能 ====================
    
    /**
     * @dev 借款函数 - 用户根据抵押品借出 ETH
     * @param amount 要借出的金额（wei）
     * 限制：
     * 1. 合约必须有足够的流动性
     * 2. 借款金额不能超过抵押品允许的最大额度
     * nonReentrant: 防止重入攻击
     */
    function borrow(uint256 amount) external nonReentrant {
        // 检查借款金额必须大于 0
        require(amount > 0, "Must borrow a positive amount");
        
        // 检查合约是否有足够的 ETH 可以借出
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        // 计算用户最多可以借的金额
        // 公式：最大借款 = 抵押品价值 * 抵押率
        // 例如：抵押 1 ETH，抵押率 75%，则最多借 0.75 ETH
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        
        // 计算用户当前的债务（包括累积的利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        // 检查借款后是否超过最大额度
        // 当前债务 + 新借款 <= 最大可借额度
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        // 更新借款余额（旧债务 + 新借款）
        borrowBalances[msg.sender] = currentDebt + amount;
        
        // 更新利息计算时间戳为当前时间
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // 将 ETH 转给用户
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "ETH transfer failed");
        
        // 触发借款事件
        emit Borrow(msg.sender, amount);
    }

    // ==================== 还款功能 ====================
    
    /**
     * @dev 还款函数 - 用户偿还借款（附带利息）
     * payable: 允许函数接收 ETH 作为还款
     * 如果还款金额超过债务，多余部分会退回
     * 
     * 安全考虑：
     * 1. 使用 Checks-Effects-Interactions 模式防止重入攻击
     * 2. 使用 nonReentrant 修饰符提供额外保护
     */
    function repay() external payable nonReentrant {
        // ========== Checks ==========
        // 检查还款金额必须大于 0
        require(msg.value > 0, "Must repay a positive amount");

        // 计算用户当前的债务（本金 + 累积利息）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        
        // 检查是否有债务需要偿还
        require(currentDebt > 0, "No debt to repay");

        // 确定实际还款金额和退款金额
        uint256 amountToRepay = msg.value;
        uint256 refundAmount = 0;
        
        // 如果还款金额超过债务，计算退款金额
        if (amountToRepay > currentDebt) {
            refundAmount = msg.value - currentDebt;
            amountToRepay = currentDebt;
        }

        // ========== Effects ==========
        // 先更新状态，防止重入攻击
        // 更新借款余额（剩余债务）
        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        
        // 更新利息计算时间戳
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        // ========== Interactions ==========
        // 最后进行外部调用（转账）
        // 如果有退款，先退款
        if (refundAmount > 0) {
            (bool sent, ) = payable(msg.sender).call{value: refundAmount}("");
            require(sent, "ETH refund failed");
        }

        // 触发还款事件
        emit Repay(msg.sender, amountToRepay);
    }

    // ==================== 利息计算 ====================
    
    /**
     * @dev 计算用户的累积债务（本金 + 利息）
     * @param user 用户地址
     * @return 总债务金额（wei）
     * 
     * 利息计算公式：
     * 利息 = 本金 * 年利率 * 时间（年）
     * 
     * 注意：这里使用简单利息计算，不是复利
     */
    function calculateInterestAccrued(address user) public view returns (uint256) {
        // 如果没有借款，返回 0
        if (borrowBalances[user] == 0) {
            return 0;
        }

        // 计算距离上次计息经过的时间（秒）
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        
        // 计算利息
        // 公式：利息 = 本金 * 利率基点 * 时间 / (10000 * 365天)
        // 10000 是因为利率以基点表示
        // 365 days 将秒转换为年
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        // 返回本金 + 利息
        return borrowBalances[user] + interest;
    }

    // ==================== 查询函数 ====================
    
    /**
     * @dev 获取用户的最大可借金额
     * @param user 用户地址
     * @return 最大可借金额（wei）
     */
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    /**
     * @dev 获取合约的总流动性（合约持有的 ETH 总量）
     * @return 合约余额（wei）
     */
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 核心概念:
//    - 存款（Deposit）: 用户存入 ETH 赚取利息
//    - 抵押品（Collateral）: 用户存入 ETH 作为借款担保
//    - 借款（Borrow）: 用户根据抵押品借出 ETH
//    - 利率（Interest Rate）: 借款的年利率，以基点表示
//    - 抵押率（Collateral Factor）: 决定可以借出多少，如 75%
//
// 2. 利息计算:
//    - 使用简单利息：利息 = 本金 × 利率 × 时间
//    - 利率单位：基点（1 基点 = 0.01%）
//    - 默认年利率：5%（500 基点）
//    - 时间单位：秒，需要转换为年
//
// 3. 抵押率机制:
//    - 默认抵押率：75%（7500 基点）
//    - 意味着抵押 1 ETH 最多借 0.75 ETH
//    - 这是为了防止价格波动导致清算
//
// 4. 安全考虑:
//    - 先更新状态，后转账（防止重入攻击）
//    - 使用 require 进行输入验证
//    - 检查合约流动性是否充足
//    - 确保抵押率不会跌破阈值
//
// 5. 与真实 DeFi 协议的区别:
//    - 真实协议使用 ERC20 代币，这里使用原生 ETH
//    - 真实协议有清算机制，这里没有
//    - 真实协议使用复利计算，这里使用单利
//    - 真实协议有价格预言机，这里没有
//    - 真实协议有治理机制调整参数，这里固定
//
// 6. 使用流程示例:
//    存款者：
//    1. deposit() - 存入 ETH
//    2. 等待赚取利息（借款人支付的利息）
//    3. withdraw() - 取回本金+收益
//    
//    借款者：
//    1. depositCollateral() - 存入抵押品
//    2. borrow() - 根据抵押品借款
//    3. 随时间累积利息
//    4. repay() - 还款（本金+利息）
//    5. withdrawCollateral() - 取回抵押品
//
// 7. 关键知识点:
//    - mapping: 键值对存储用户数据
//    - view 函数: 不修改状态，只读取
//    - payable: 允许接收和发送 ETH
//    - block.timestamp: 当前区块时间戳
//    - 时间单位: seconds, minutes, hours, days
//    - 数学运算: 整数除法会截断小数
