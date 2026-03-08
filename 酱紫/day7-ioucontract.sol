// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 简易借贷合约 (SimpleIOU)
 * @dev 演示了以太坊内部账本管理、权限控制及正确的 ETH 转账逻辑
 */
contract SimpleIOU {
    address public owner;
    
    mapping(address => bool) public registeredFriends;
    address[] public friendList;
    
    // 内部账本：记录用户存放在合约里的 ETH 余额
    mapping(address => uint256) public balances;
    
    // 债务追踪：debtor -> creditor -> amount
    mapping(address => mapping(address => uint256)) public debts;

    // 事件：用于前端监听和链下追踪
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event DebtRecorded(address indexed debtor, address indexed creditor, uint256 amount);

    constructor() {
        owner = msg.sender;
        registeredFriends[msg.sender] = true;
        friendList.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }

    /**
     * @dev 添加新成员到白名单
     * @param _friend 新成员地址
     */
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address");
        require(!registeredFriends[_friend], "Friend already registered");
        
        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }

    /**
     * @dev 存入 ETH 到合约钱包
     * 发送的 ETH 会增加调用者在合约内部的余额
     */
    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 记录一笔债务
     * @param _debtor 欠款人地址
     * @param _amount 欠款数额
     */
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(registeredFriends[_debtor], "Debtor not registered");
        require(_amount > 0, "Amount must > 0");
        
        debts[_debtor][msg.sender] += _amount;
        emit DebtRecorded(_debtor, msg.sender, _amount);
    }

    /**
     * @dev 使用合约内的内部余额偿还债务
     * 此操作仅在合约账本内划转数字，不涉及外部转账
     * @param _creditor 债权人地址
     * @param _amount 偿还数额
     */
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(debts[msg.sender][_creditor] >= _amount, "Insufficient debt recorded");
        require(balances[msg.sender] >= _amount, "Insufficient wallet balance");
        
        // 修改账本状态
        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }

    /**
     * @dev [修正版] 提取余额并转账给其他成员
     * 逻辑：扣除自己的内部余额，直接发送 ETH 到对方的外部钱包。
     * 注意：不再增加对方的 balances 内部余额，防止“双重给钱”。
     */
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // 1. 先修改状态（防重入）
        balances[msg.sender] -= _amount;
        
        // 2. 发送真钱
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev 提现功能
     * 将合约中的内部余额提现到调用者的外部钱包
     */
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @dev 查询当前用户的内部余额
     */
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
