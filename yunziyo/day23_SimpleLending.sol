// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLending {
    mapping(address => uint256) public depositBalances;
    mapping(address => uint256) public borrowBalances;
    mapping(address => uint256) public collateralBalances;
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    uint256 public constant INTEREST_RATE_BP = 500;
    uint256 public constant COLLATERAL_FACTOR_BP = 7500;
    uint256 private constant SECONDS_PER_YEAR = 365 days;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    modifier updateInterest(address user) {
        if (borrowBalances[user] > 0) {
            borrowBalances[user] = getFullDebt(user);
        }
        lastInterestAccrualTimestamp[user] = block.timestamp;
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Amount must be positive");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be positive");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        
        depositBalances[msg.sender] -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdraw(msg.sender, amount);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "Collateral must be positive");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external updateInterest(msg.sender) {
        require(amount > 0, "Amount must be positive");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 currentDebt = borrowBalances[msg.sender];
        uint256 requiredCollateral = (currentDebt * 10000) / COLLATERAL_FACTOR_BP;

        require(
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal breaks collateral ratio"
        );

        collateralBalances[msg.sender] -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function borrow(uint256 amount) external updateInterest(msg.sender) {
        require(amount > 0, "Amount must be positive");
        
        uint256 maxBorrow = (collateralBalances[msg.sender] * COLLATERAL_FACTOR_BP) / 10000;
        require(borrowBalances[msg.sender] + amount <= maxBorrow, "Exceeds max borrow limit");
        require(address(this).balance >= amount, "Insufficient pool liquidity");

        borrowBalances[msg.sender] += amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable updateInterest(msg.sender) {
        uint256 currentDebt = borrowBalances[msg.sender]; 
        require(currentDebt > 0, "No active debt");
        require(msg.value > 0, "Repayment must be positive");

        uint256 actualRepay = msg.value;
        
        if (msg.value > currentDebt) {
            actualRepay = currentDebt;
            uint256 refund = msg.value - currentDebt;
            (bool success, ) = msg.sender.call{value: refund}("");
            require(success, "Refund failed");
        }

        borrowBalances[msg.sender] -= actualRepay;
        emit Repay(msg.sender, actualRepay);
    }

    function getFullDebt(address user) public view returns (uint256) {
        uint256 principal = borrowBalances[user];
        if (principal == 0) return 0;

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (principal * INTEREST_RATE_BP * timeElapsed) / (10000 * SECONDS_PER_YEAR);
        return principal + interest;
    }

    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}
