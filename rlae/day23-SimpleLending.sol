// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */
 contract SimpleLending {
    mapping(address => uint256) public depositBalances; //这个映射记录用户存入借贷池的 ETH 数量
    mapping(address => uint256) public borrowBalances; //显示了用户从池中借了多少 ETH
    mapping(address => uint256) public collateralBalances; //安全网,要借款，你需要抵押资产。这个映射记录了每个用户提供的作为抵押的 ETH 数量。押金
    mapping(address => uint256) public lastInterestAccrualTimestamp; //记录每个用户上次计算利息的时间(会每秒自动累积——那会非常耗费 gas)
    uint256 public interestRateBasisPoints = 500;         // 5% annual interest rate 借款人每年需支付的贷款利率
    uint256 public collateralFactorBasisPoints = 7500;    // 75% loan-to-value (LTV) 用户只能借入他们作为抵押锁定 ETH 的 75%
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount); //当用户发送 ETH 以偿还贷款时触发
    event CollateralDeposited(address indexed user, uint256 amount); //当用户将 ETH 锁定作为抵押品时发出
    event CollateralWithdrawn(address indexed user, uint256 amount); //当用户安全提取其抵押品时发生
    function deposit() external payable {
    require(msg.value > 0, "Must deposit a positive amount");

    depositBalances[msg.sender] += msg.value;

    emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount) external {
    require(amount > 0, "Must withdraw a positive amount");
    require(depositBalances[msg.sender] >= amount, "Insufficient balance");

    depositBalances[msg.sender] -= amount; //余额将得到更新
    //payable(msg.sender).transfer(amount); // Solidity 要求对可支付地址调用 .transfer() 
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Transfer failed");

    emit Withdraw(msg.sender, amount);
    }
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
        return 0; //检查用户是否借过任何款项
        }
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);
        return borrowBalances[user] + interest; // 返回总债务（本金+利息
    }
    function depositCollateral() external payable {
    require(msg.value > 0, "Must deposit a positive amount as collateral");

    collateralBalances[msg.sender] += msg.value;// 抵押++ 

    emit CollateralDeposited(msg.sender, msg.value);
    }
    function withdrawCollateral(uint256 amount) external {
    require(amount > 0, "Must withdraw a positive amount");
    require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

    uint256 borrowedAmount = calculateInterestAccrued(msg.sender); //检查他们欠多少债务,包括他们随时间累积的任何利息
    uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints; // amount*1/0.75

    require(
        collateralBalances[msg.sender] - amount >= requiredCollateral, // 抵押余额-withdraw>=抵押转换后的债务
        "Withdrawal would break collateral ratio"
    );

    collateralBalances[msg.sender] -= amount; // 抵押余额--
    (bool success, )= payable(msg.sender).call{value: amount}("");
    require(success, "Transfer failed");

    emit CollateralWithdrawn(msg.sender, amount);
    }
    function borrow(uint256 amount) external {
    require(amount > 0, "Must borrow a positive amount"); //确保用户不是试图借入零 ETH 或负数金额
    require(address(this).balance >= amount, "Not enough liquidity in the pool"); //该合约检查自身余额，以确认是否真的能够借出那么多 ETH

    uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000; //计算其可借款金额 X ETH*0.75
    uint256 currentDebt = calculateInterestAccrued(msg.sender); //考虑他们已经欠下的任何债务+利息

    require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount"); //债务+杰出《=总额度

    borrowBalances[msg.sender] = currentDebt + amount;
    lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

    //payable(msg.sender).transfer(amount);
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Transfer failed");
    emit Borrow(msg.sender, amount);
    }
    function repay() external payable {
    require(msg.value > 0, "Must repay a positive amount");

    uint256 currentDebt = calculateInterestAccrued(msg.sender); //欠多少——包括累积的任何利息
    require(currentDebt > 0, "No debt to repay");

    uint256 amountToRepay = msg.value; //记录用户尝试还款的金额
    if (amountToRepay > currentDebt) {
        amountToRepay = currentDebt;
        //际上是在告诉合约：“虽然用户给了 120，但我们要处理的有效业务金额只有 100。” 这样在触发 emit Repaid(msg.sender, amountToRepay) 事件时，链下浏览器（如 Etherscan）显示的还款金额才是准确的 100 ETH，而不是带干扰的 120 ETH。
        //payable(msg.sender).transfer(msg.value - currentDebt); // Refund the extra //自动退还多余的 ETH
        (bool success, )=payable(msg.sender).call{value: msg.value - currentDebt}("");
        require(success, "Transfer failed");
    }

    borrowBalances[msg.sender] = currentDebt - amountToRepay;
    lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

    emit Repay(msg.sender, amountToRepay);
    
    }
    function getMaxBorrowAmount(address user) external view returns (uint256) {
    return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }
    function getTotalLiquidity() external view returns (uint256) {
    return address(this).balance; //当前借贷池持有多少 ETH
    }





}