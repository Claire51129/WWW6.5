// DeFi借贷合约(mini版)/一个区块链银行，可以实现：存钱(赚利息、抵押资产、借钱、还钱、控制风险-防止借太多)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */
contract SimpleLending {
    // 存款余额：每个人存了多少钱 Token balances for each user
    mapping(address => uint256) public depositBalances;

    // 借款余额：每个人借了多少钱 Borrowed amounts for each user
    mapping(address => uint256) public borrowBalances;

    // 抵押资产：每个人抵押了多少ETH Collateral provided by each user
    mapping(address => uint256) public collateralBalances;

    // basis points(基点)10000=100%，500=5%；Interest rate in basis points (1/100 of a percent)
    // 利率=5%；500 basis points = 5% interest
    uint256 public interestRateBasisPoints = 500;

    // 抵押率=75%，即你抵押 100 ETH → 最多借 75 ETH；Collateral factor in basis points (e.g., 7500 = 75%)
    // 防止你借太多跑路 Determines how much you can borrow against your collateral
    uint256 public collateralFactorBasisPoints = 7500;

    // 记录上次算利息时间；Timestamp of last interest accrual；利息=时间X利率
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // 记录日志Events(给前端用-方便前端捕捉更新)
    event Deposit(address indexed user, uint256 amount);   //你 存 了X ETH，以下同理
    event Withdraw(address indexed user, uint256 amount);  //提款
    event Borrow(address indexed user, uint256 amount);   //借
    event Repay(address indexed user, uint256 amount);   //偿还
    event CollateralDeposited(address indexed user, uint256 amount);   //ETH抵押
    event CollateralWithdrawn(address indexed user, uint256 amount);  //取回抵押

    // 用户存ETH
    function deposit() external payable {   //payable=可以收钱
        require(msg.value > 0, "Must deposit a positive amount");   //必须存钱>0
        depositBalances[msg.sender] += msg.value;   //更新余额；“更新这个用户的银行余额。”
        emit Deposit(msg.sender, msg.value);   //msg.sender=调用函数的人，即存款人；触发存款事件，前端应用或索引器可以监听该事件。确保 UI 更新并在 Etherscan 等工具中记录交易的方式。
    }

    // 用户取钱
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");    //不能取超过自己存的(验证提款请求)
        depositBalances[msg.sender] -= amount;    //扣余额(更新余额)
        (bool success, ) = payable(msg.sender).call{value: amount}("");       //把钱转回用户的钱包
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);    //触发提款事件——一个你的前端可以监听以显示类似确认消息的信号：“√成功提款 0.5 ETH！”
    }   //Solidity 要求对可支付地址调用 .transfer() —— 这就是为什么我们将 msg.sender 强制转换为 payable(msg.sender)。

    // 抵押资产(ETH)
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");   //检查真实存款
        collateralBalances[msg.sender] += msg.value;   //增加抵押
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // 【重点】取回抵押——拿回你锁定/抵押的ETH
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);    //当前债务(含利息)
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;   //计算最少需要多少抵押才能保持安全，如:假设你欠 1 ETH，LTV 为 75%：你需要至少 1 / 0.75 = 1.33 ETH 作为抵押品锁定。

        require(    //核心风控！防止把抵押取走但还欠钱的情况发生
            collateralBalances[msg.sender] - amount >= requiredCollateral,
            "Withdrawal would break collateral ratio"
        );   //如果移除该 ETH 会导致你低于安全限制，我们将回滚交易。

        collateralBalances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit CollateralWithdrawn(msg.sender, amount);
    }   //如果你通过所有检查，你就可以继续。——将 ETH 发回你的钱包，并发出一个事件通知前端。

    // 【核心】借钱
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");   //检查贷款数>0
        require(address(this).balance >= amount, "Not enough liquidity in the pool");   //确保池中有流动性  

        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;    //检查借款人资格，根据用户提供的抵押品数量，计算其最大可借金额
        uint256 currentDebt = calculateInterestAccrued(msg.sender);    //当前债务(含利息)

        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");   //不能借超过最大数额

        borrowBalances[msg.sender] = currentDebt + amount;    //更新债务
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;   //记录时间(开始计息)

        (bool success, ) = payable(msg.sender).call{value: amount}("");    //给用户钱(转移ETH)
        require(success, "Transfer failed");    
        emit Borrow(msg.sender, amount);   //发出借出时间，这向外界（你的前端、区块浏览器、分析仪表板）表明这位用户刚刚借了款。
    }

    // 还款
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);   //计算总债务(含利息)
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;    //接受你发送的内容——记录用户尝试还款的金额
        if (amountToRepay > currentDebt) {   //如果还多了
            amountToRepay = currentDebt;
            (bool success, ) = payable(msg.sender).call{value: msg.value - currentDebt}("");   //多的钱退回
            require(success, "Refund failed");
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;   //更新债务
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        emit Repay(msg.sender, amountToRepay);   //触发还款事件
    }

    // 【超重点】利息计算(借款核心)
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {    //检查用户是否借过任何款项
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];   //时间差：计算已过去多长时间；block.timestamp=当前时间；lastInterestAccrualTimestamp 告诉我们上次更新他们债务的时间。
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);
        //↑利息公式——利息=本金X利率X时间。borrowBalances[user] → 用户的当前贷款本金；interestRateBasisPoints → 我们的年利率（例如，500等于5%）；timeElapsed → 他们欠债的时间长度；10000 * 365 days → 用于将基准点转换为年度分数
        return borrowBalances[user] + interest;   //返回总债务：本金+利息
    }

    // 工具函数：支持UI与集成的辅助工具(查询)
    function getMaxBorrowAmount(address user) external view returns (uint256) {   //查询最大可借
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }    //所以如果有人锁定了 4 ETH，而我们的抵押率是 75%，这个函数将返回：4 × 0.75 = 3 ETH → 那就是他们的最大可借额度;
    // 这对前端开发非常有用：它允许界面显示：“你可以借最多 3 ETH”;或者显示一个进度条，展示他们已使用的借款额度

    // 查询池子里总资金(实时的资金情况)，就像检查银行的保险库余额。
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }    //前端可以使用这个功能：显示总池大小;指示是否有足够的流动性来满足借贷请求;若资金池余额不足，请提醒用户
}



// 该合约核心机制：1>抵押借贷——没抵押不能借；2>超额抵押——抵押>借款(防跑路)；3>利息随时间增长：借越久→还越久；4>风险控制：防止用户把抵押拿走。
// 基点BasisPoints在金融中用于精确表达百分比，尤其是在处理分数利率时。1 个基点是 0.01%，所以 500 个基点是 5%
// Solidity不支持小数，也不支持浮点数预算，以保持极高的精确度
// Q:为什么抵押要有差值，只能按价值的75%来贷? A:因为存在价格波动。ETH 明天可能会贬值。所以我们总是希望借款人留下一层安全垫——这就是抵押率强制执行的机制。这有助于协议避免亏损，并确保借款人始终有足够的抵押物来支持他们的贷款。现实中的比喻：这就像银行说“我们可以用你的车作为抵押贷款——但只能按其当前价值的 75%来贷。”
// functions可以使合约变得能与用户交互，点击实现不同的功能
// emit：我们发出事件，以便前端和工具能够对存款做出反应——更新仪表板、发送通知，并将操作记录在历史中。

