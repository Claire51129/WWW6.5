// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */
contract SimpleLending {
    // 数字保险库
    mapping(address => uint256) public depositBalances;

    // 贷款账簿
    mapping(address => uint256) public borrowBalances;

    // 安全网
    mapping(address => uint256) public collateralBalances;

 // 设定金融规则
    uint256 public interestRateBasisPoints = 500;

    uint256 public collateralFactorBasisPoints = 7500;

    // 计时员
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // Events
    event Deposit(address indexed user, uint256 amount);//存款
    event Withdraw(address indexed user, uint256 amount);//取钱
    event Borrow(address indexed user, uint256 amount);//借贷
    event Repay(address indexed user, uint256 amount);//还款
    event CollateralDeposited(address indexed user, uint256 amount);//将 ETH 锁定作为抵押品时
    event CollateralWithdrawn(address indexed user, uint256 amount);//用户安全提取其抵押品时发生
//  向池中添加 ETH
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;//更新这个用户的银行余额
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        //  Solidity 要求对可支付地址调用 .transfer() 
        payable(msg.sender).transfer(amount);//合约将 ETH 发送回用户
        emit Withdraw(msg.sender, amount);
    }
// 锁定 ETH 以便日后借款
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        // 好了，这位用户现在已经锁定了 X ETH——我们可以让他们在某个限额内安全地借款
        emit CollateralDeposited(msg.sender, msg.value);
    }
// 
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        // 确保他们确实有足够的抵押品来尝试这一点。
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        // 计算他们需要多少抵押品才能保持安全
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;
// 这是基于我们之前设置的贷款价值比（LTV）—— 默认为 75%。
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
        // 我们更新你的记录，将 ETH 发回你的钱包，并发出一个事件通知前端
    }
// 解锁 DeFi 的超级能力：借入 ETH
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");
/**检查借款人资格**

我们根据用户提供的抵押品数量，计算其可借款金额**/
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        // 债务+利息
        uint256 currentDebt = calculateInterestAccrued(msg.sender);

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");
//  更新债务和时间
        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
// 转移 ETH
        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

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
// 借款的核心
/**- ✅ 当你借入
- 💳 当你偿还
- 🔓 当你提取抵押品
- 📊 即使在查询你欠多少时**/
    function calculateInterestAccrued(address user) public view returns (uint256) {
    //    1. 检查用户是否借过任何款项
        if (borrowBalances[user] == 0) {
            return 0;
        }
// 2. 计算已过去多少时间
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
    //  3. 应用利息公式
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);
// 4. 返回总债务（本金+利息）
        return borrowBalances[user] + interest;
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}

