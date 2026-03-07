// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU {
    address public owner;
    uint256 public constant ANNUAL_INTEREST_RATE = 5; // 假设年利率 5%

    struct DebtInfo {
        uint256 principal;   // 本金
        uint256 lastUpdate;  // 上次计算利息的时间戳
    }

    mapping(address => bool) public registeredFriends;
    mapping(address => uint256) public balances;
    
    // debts[债务人][债权人] = 债务详情
    mapping(address => mapping(address => DebtInfo)) public debts;
    address[] public friendList;

    // 事件记录
    event DebtChanged(address indexed debtor, address indexed creditor, uint256 newAmount, string action);
    event DebtTransferred(address indexed debtor, address indexed oldCreditor, address indexed newCreditor, uint256 amount);

    constructor() {
        owner = msg.sender;
        registeredFriends[msg.sender] = true;
        friendList.push(msg.sender);
    }

    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "Not registered");
        _;
    }

    // --- 核心功能实现 ---

    // 1. 计算利息后的实时债务 (内部工具函数)
    function getDebtWithInterest(address _debtor, address _creditor) public view returns (uint256) {
        DebtInfo storage debt = debts[_debtor][_creditor];
        if (debt.principal == 0) return 0;

        uint256 timePassed = block.timestamp - debt.lastUpdate;
        // 简单利息计算公式: 本金 * (1 + 利率 * 时间 / 年总秒数)
        // 注意: Solidity 不支持浮点数，需要先乘后除
        uint256 interest = (debt.principal * ANNUAL_INTEREST_RATE * timePassed) / (365 days * 100);
        return debt.principal + interest;
    }

    // 2. 获取某人的总欠款 (需要遍历 friendList)
    function getTotalDebt(address _debtor) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < friendList.length; i++) {
            total += getDebtWithInterest(_debtor, friendList[i]);
        }
        return total;
    }

    // 3. 记录债务 (初始化时间戳)
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(registeredFriends[_debtor], "Debtor not registered");
        
        // 如果已有债务，先结算旧利息再叠加新本金
        uint256 currentFullAmount = getDebtWithInterest(_debtor, msg.sender);
        debts[_debtor][msg.sender] = DebtInfo({
            principal: currentFullAmount + _amount,
            lastUpdate: block.timestamp
        });

        emit DebtChanged(_debtor, msg.sender, currentFullAmount + _amount, "Record");
    }

    // 4. 部分还款或全额清算
    function payDebt(address _creditor, uint256 _payAmount) public onlyRegistered {
        uint256 currentFullAmount = getDebtWithInterest(msg.sender, _creditor);
        require(currentFullAmount >= _payAmount, "Paying more than owed");
        require(balances[msg.sender] >= _payAmount, "Insufficient wallet balance");

        balances[msg.sender] -= _payAmount;
        balances[_creditor] += _payAmount;

        // 更新债务状态
        debts[msg.sender][_creditor] = DebtInfo({
            principal: currentFullAmount - _payAmount,
            lastUpdate: block.timestamp
        });

        emit DebtChanged(msg.sender, _creditor, currentFullAmount - _payAmount, "Payment");
    }

    // 5. 债务转移 (A欠B, B欠C -> A欠C)
    // 条件：msg.sender 是 B (原债权人)，他想把 A 欠他的钱用来抵扣他欠 C 的钱
    function transferDebt(address _debtorA, address _newCreditorC, uint256 _amount) public onlyRegistered {
        uint256 debtAToB = getDebtWithInterest(_debtorA, msg.sender);
        require(debtAToB >= _amount, "B does not hold enough debt from A");

        // 1. 减少 A 欠 B 的债
        debts[_debtorA][msg.sender].principal = debtAToB - _amount;
        debts[_debtorA][msg.sender].lastUpdate = block.timestamp;

        // 2. 增加 A 欠 C 的债
        uint256 existingDebtAToC = getDebtWithInterest(_debtorA, _newCreditorC);
        debts[_debtorA][_newCreditorC] = DebtInfo({
            principal: existingDebtAToC + _amount,
            lastUpdate: block.timestamp
        });

        emit DebtTransferred(_debtorA, msg.sender, _newCreditorC, _amount);
    }
}