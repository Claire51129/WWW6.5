pragma solidity ^0.8.0;

/**
 * @title 简易借据应用 (SimpleIOU)
 * 本合约演示了一个简单的朋友间借记管理系统：
 * 1. 管理员 (Owner) 可以添加朋友。
 * 2. 只有注册的朋友可以存款、记录债务、转账和取款。
 * 3. 涵盖了嵌套映射 (Nested Mapping) 和多种 ETH 转账方式。
 */
contract SimpleIOU {
    // 合约所有者地址 (管理员)
    address public owner;
    
    // --- 状态变量 (存储在区块链上) ---

    // 映射：记录地址是否已注册为朋友。 mapping(地址 => 是否注册)
    mapping(address => bool) public registeredFriends;
    
    // 数组：存储所有已注册朋友的地址列表
    address[] public friendList;
    
    // 映射：记录每个人的内部余额 (单位：Wei)
    mapping(address => uint256) public balances;
    
    // 嵌套映射：记录债务关系。 
    // debts[债务人][债权人] = 欠款金额
    // 例如：debts[A][B] = 100 表示 A 欠 B 100 Wei
    mapping(address => mapping(address => uint256)) public debts; 
    
    // --- 构造函数 (部署合约时执行一次) ---
    constructor() {
        owner = msg.sender; // 部署者设为所有者
        registeredFriends[msg.sender] = true; // 将所有者也注册为朋友
        friendList.push(msg.sender);
    }
    
    // --- 函数修改器 (权限控制) ---

    // 限制仅合约所有者可操作
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 限制仅已注册朋友可操作
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    // --- 核心业务逻辑 ---

    /**
     * @dev 注册新朋友 (仅限管理员调用)
     * @param _friend 要添加的朋友地址
     */
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address");
        require(!registeredFriends[_friend], "Friend already registered");
        
        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }
    
    /**
     * @dev 存入 ETH 到合约内部钱包
     * payable 关键字：使函数能够接收随交易发送的 ETH
     */
    function depositIntoWallet() public payable onlyRegistered {
        // msg.value 是发送的 ETH 数量（单位：Wei）
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
    }
    
    /**
     * @dev 记录债务：记录某人欠调用者多少钱
     * @param _debtor 债务人地址
     * @param _amount 欠款金额
     */
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(registeredFriends[_debtor], "Address not registered");
        require(_amount > 0, "Amount must be greater than 0");
        
        // 更新嵌套映射中的数值
        debts[_debtor][msg.sender] += _amount;
    }
    
    /**
     * @dev 内部还款：使用合约内的余额来偿还对某人的债务
     * @param _creditor 债权人地址
     * @param _amount 还款金额
     */
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(_creditor != address(0), "Invalid address");
        require(registeredFriends[_creditor], "Creditor not registered");
        require(_amount > 0, "Amount must be greater than 0");
        
        // 校验：当前调用者确实欠对方这么多钱
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect");
        // 校验：当前调用者在合约里的余额足够还款
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 更新账本余额和债务记录
        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }
    
    /**
     * @dev 直接转账方法：使用 Solidity 原生的 transfer()
     * @param _to 接收者地址 (必须是 payable 类型才能收钱)
     * @param _amount 转账金额
     */
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        // .transfer() 是一种简单的转账方式，如果失败会自动报错并回滚
        _to.transfer(_amount);
        balances[_to] += _amount;
    }
    
    /**
     * @dev 替代转账方法：使用更现代的 call() 方式
     * call() 相比 transfer() 更灵活，不容易因为 gas 限制导致转账失败
     */
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        // .call{value: 金额}("") 返回 (是否成功, 返回数据)
        (bool success, ) = _to.call{value: _amount}("");
        balances[_to] += _amount;
        require(success, "Transfer failed"); // 必须手动校验成功标志
    }
    
    /**
     * @dev 提现：将合约内的余额提取到自己的钱包
     */
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        // 将地址显式转换为 payable 类型以进行转账
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }
    
    /**
     * @dev 查询调用者自己的余额
     */
    function checkBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }
}