// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLending 
{
    mapping(address => uint256) public depositBalances;//存储账户
    mapping(address => uint256) public borrowBalances;//借贷账户
    mapping(address => uint256) public collateralBalances;//抵押账户

    // Interest rate in basis points (1/100 of a percent)
    // 500 basis points = 5% interest
    uint256 public interestRateBasisPoints = 500;//贷款利率

    // Collateral factor in basis points (e.g., 7500 = 75%)
    // Determines how much you can borrow against your collateral
    uint256 public collateralFactorBasisPoints = 7500;//用户只能借入他们作为抵押锁定 ETH 的 75%

    // Timestamp of last interest accrual
    mapping(address => uint256) public lastInterestAccrualTimestamp;//时间戳，用于计算利息

    // 事件
    event Deposit(address indexed user, uint256 amount);//存款
    event Withdraw(address indexed user, uint256 amount);//取款
    event Borrow(address indexed user, uint256 amount);//借贷
    event Repay(address indexed user, uint256 amount);//还贷
    event CollateralDeposited(address indexed user, uint256 amount);//抵押贷款额度
    event CollateralWithdrawn(address indexed user, uint256 amount);//提取抵押品

    function deposit() external payable 
    {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;//接收ETH，更新余额
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external 
    {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function depositCollateral() external payable 
    {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;//抵押品余额
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external //取出抵押品
    {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");
        //足够的抵押品
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;
        //抵押品够不够现在的债务
        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,//抵押品不足会拒绝交易
            "Withdrawal would break collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function borrow(uint256 amount) external //申请贷款
    {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");
        //确保流动资金充足
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        //检查借款人资格
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        //检查当前债务+利息
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);//转移ETH
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable //还贷
    {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) 
        {
            amountToRepay = currentDebt;
            payable(msg.sender).transfer(msg.value - currentDebt);//退款多余部分
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;//更新贷款余额
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);
    }

    function calculateInterestAccrued(address user) public view returns (uint256) 
    {
        if (borrowBalances[user] == 0) //是否有贷款
        {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];//算时间
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);//算利息

        return borrowBalances[user] + interest;//总债务
    }

    function getMaxBorrowAmount(address user) external view returns (uint256) //计算抵押品支持的最高贷款
    {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) //借贷池有多少现金流
    {
        return address(this).balance;
    }
}

