//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
  * @title SimpleLending
  * @dev A basic DeFi lending and borrowing platform.
  */

contract SimpleLending {
  //Token balances for user
  mapping(address => uint256) public depositBalances;
  //borrowed amounts for user
  mapping(address => uint256) public borrowBalances;
  //collateral balances for user
  mapping(address => uint256) public collateralBalances;
  //Interest rate in basis points (100 = 1%)
  //500 basic points = 5% interest rate
  uint256 public interestRateBasisPoints = 500;
  //Collateral factor in basis points (e.g., 7500 = 75%)
  //depends how much you can borrow against your collateral
  uint256 public collateralFactorBasisPoints = 7500;
  //Timestamp of last interest accrual
  mapping(address => uint256) public lastInterestAccrualTimeStamp;
  
  //events
  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Borrow(address indexed user, uint256 amount);
  event Repay(address indexed user, uint256 amount);
  event CollateralDeposited(address indexed user, uint256 amount);
  event CollateralWithdrawn(address indexed user, uint256 amount);

  function deposit() external payable {
    require(msg.value > 0, "Deposit amount must be greater than zero");
    depositBalances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint256 amount) external {
    require(amount > 0, "Withdraw amount must be greater than zero");
    require(depositBalances[msg.sender] >= amount, "Insufficient balance to withdraw");
    depositBalances[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
    emit Withdraw(msg.sender, amount);
  }

  function depositCollateral() external payable {
    require(msg.value > 0, "Collateral amount must be greater than zero");
    collateralBalances[msg.sender] += msg.value;
    emit CollateralDeposited(msg.sender, msg.value);
  }

  function withdrawCollateral(uint256 amount) external {
    require(amount > 0, "Collateral withdraw amount must be greater than zero");
    require(collateralBalances[msg.sender] >= amount, "Insufficient collateral to withdraw");
    
    uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
    uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;

    require(
      collateralBalances[msg.sender] - amount >= requiredCollateral,
      "Cannot withdraw collateral that would undercollateralize the loan"
    );

    collateralBalances[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
    emit CollateralWithdrawn(msg.sender, amount);
  }

  function borrow(uint256 amount) external {
    require(amount > 0, "Borrow amount must be greater than zero");
    require(address(this).balance >= amount, "Insufficient liquidity in the contract");
    //max borrow = collateral balance * collateral factor(solidity stores percentage as basis points, so we divide by 10000)
    uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
    uint256 currentDebt = calculateInterestAccrued(msg.sender);

    require(currentDebt + amount <= maxBorrowAmount, "Borrow amount exceeds maximum allowed based on collateral");

    borrowBalances[msg.sender] = currentDebt + amount;
    lastInterestAccrualTimeStamp[msg.sender] = block.timestamp;

    payable(msg.sender).transfer(amount);
    emit Borrow(msg.sender, amount);
  }

  function repay() external payable {
    require(msg.value > 0, "Repay amount must be greater than zero");
    uint256 currentDebt = calculateInterestAccrued(msg.sender);
    require(currentDebt > 0, "No outstanding debt to repay");

    uint256 repayAmount = msg.value;
    if (repayAmount > currentDebt) {
      repayAmount = currentDebt; // Cap repay amount to current debt
      payable(msg.sender).transfer(msg.value - repayAmount); // Refund excess payment
    }

    borrowBalances[msg.sender] = currentDebt - repayAmount;
    lastInterestAccrualTimeStamp[msg.sender] = block.timestamp;
    emit Repay(msg.sender, repayAmount);
  }

  function calculateInterestAccrued(address user) public view returns (uint256) {
    if (borrowBalances[user] == 0) {
      return 0;
    }

    uint256 timeElapsed = block.timestamp - lastInterestAccrualTimeStamp[user];
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