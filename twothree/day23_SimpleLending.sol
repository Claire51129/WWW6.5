// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//合同名字：简单借贷平台
//作用：存钱、借钱、抵押、还钱
contract SimpleLending {
//开始写借贷合同

    // 这些是账本，记录每个人的钱
    // 用户存款余额
    mapping(address => uint256) public depositBalances;
    // 一个大账本：记录【谁存了多少钱】

    // 用户借款余额
    mapping(address => uint256) public borrowBalances;
    // 一个大账本：记录【谁借了多少钱】

    // 用户抵押余额
    mapping(address => uint256) public collateralBalances;
    //一个大账本：记录【谁押了多少钱当担保】

    // 利率（500 = 5%）
    uint256 public interestRateBasisPoints = 500;
    // 借钱利息：5%（一年）

    // 抵押率（7500 = 75%）
    uint256 public collateralFactorBasisPoints = 7500;
    //  抵押规则：押100块，最多能借75块

    // 上次计息时间
    mapping(address => uint256) public lastInterestAccrualTimestamp;
    //  记录：每个人上次算利息是什么时候

    //事件相当于大喇叭，告诉大家发生了什么

    event Deposit(address indexed user, uint256 amount);
    // 广播：XXX 存了多少钱
    event Withdraw(address indexed user, uint256 amount);
    // 广播：XXX 取了多少钱
    event Borrow(address indexed user, uint256 amount);
    // 广播：XXX 借了多少钱
    event Repay(address indexed user, uint256 amount);
    // 广播：XXX 还了多少钱
    event CollateralDeposited(address indexed user, uint256 amount);
    // 广播：XXX 押了多少钱做担保
    event CollateralWithdrawn(address indexed user, uint256 amount);
    // 广播：XXX 取回了抵押的钱

    // 功能：把钱存进来
    function deposit() external payable {
        // 存钱按钮，谁都能用
        // 金额必须大于0
        require(msg.value > 0, "Amount must be greater than 0");
        // 必须存大于0的钱，不能存0
        depositBalances[msg.sender] += msg.value;
        // 把你存的钱，加到你的存款账本里
        emit Deposit(msg.sender, msg.value);
        // 广播：XXX 存了多少钱
    }

    // 功能：把自己存的钱取走
    function withdraw(uint256 amount) external {
        //  取钱按钮
        require(amount > 0, "Amount must be greater than 0");
        // 必须取大于0的钱
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        // 你取的钱，不能超过你存的钱
        // 先更新状态
        depositBalances[msg.sender] -= amount;
        //  从你的存款里减掉取走的钱

        //安全转账方法（替换了旧的 transfer）
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // 把钱转给用户，安全不报错
        require(success, "Transfer failed");
        // 转账失败就回滚，保证安全

        emit Withdraw(msg.sender, amount);
        // 公开记录：谁取了多少钱
    }

    // 功能：押钱做担保（为了借钱）
    function depositCollateral() external payable {
        // 押钱按钮
        require(msg.value > 0, "Amount must be greater than 0");
        // 必须押大于0的钱
        collateralBalances[msg.sender] += msg.value;
        // 把你押的钱，记到抵押账本里
        emit CollateralDeposited(msg.sender, msg.value);
        //  广播：XXX 押了多少钱
    }

    // 功能：把抵押的钱取回来
    function withdrawCollateral(uint256 amount) external {
        // 取回抵押金按钮
        require(amount > 0, "Amount must be greater than 0");
        // 必须取大于0的钱
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");
        // 不能取超过你押的钱

        // 当前债务（含利息）
        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        // 先算你现在一共欠多少钱（本金+利息）

        // 最低抵押要求
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;
        // 算你必须留多少抵押金，才能保证安全

        require(collateralBalances[msg.sender] - amount >= requiredCollateral, "Collateral ratio too low");
        // 不能把抵押金取光，必须留够担保额度

        collateralBalances[msg.sender] -= amount;
        // 从抵押金里减掉取走的钱

        // 安全转账方法
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // 功能：借钱
    function borrow(uint256 amount) external {
        // 借钱按钮
        require(amount > 0, "Amount must be greater than 0");
        // 必须借大于0的钱
        require(address(this).balance >= amount, "Insufficient liquidity");
        //平台里要有足够的钱才能借你
        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        //算你最多能借多少钱（押100最多借75）
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        //算你现在已经欠了多少钱
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds borrow limit");
        //新借的 + 旧欠的，不能超过上限
        borrowBalances[msg.sender] = currentDebt + amount;
        //更新你的欠款账本
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
        //记录现在时间，下次从现在开始算利息

        // 安全转账
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Borrow(msg.sender, amount);
    }

    //功能：还钱
    function repay() external payable {
        //还钱按钮
        require(msg.value > 0, "Amount must be greater than 0");
        //必须还大于0的钱
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        //先算你现在一共欠多少（本金+利息）
        require(currentDebt > 0, "No debt");
        //你必须有欠款才能还

        uint256 amountToRepay = msg.value;

        // 多还的话，退回多余的钱
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            (bool success, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");
            require(success, "Refund failed");
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
        emit Repay(msg.sender, amountToRepay);
    }

    //功能：算你欠了多少利息
    function calculateInterestAccrued(address user) public view returns (uint256) {
        //算利息工具
        if (borrowBalances[user] == 0) {
            return 0;
        }
        // 没借钱就没有利息
        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        //算距离上次算利息过了多少时间
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);
        //按时间、本金、利率算利息
        return borrowBalances[user] + interest;
        //返回：本金 + 利息 = 总欠款
    }

    // 功能：查信息
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        //查询：这个人最多能借多少钱
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    function getTotalLiquidity() external view returns (uint256) {
        //查询：平台里一共有多少钱
        return address(this).balance;
    }
}
