// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {

    // 全局变量
    // 银行管理员地址，通常是合约部署者
    address public bankManager;
    
    // 存储所有已注册成员地址的动态数组
    address[] members;
    
    // 映射：用于快速检查某个地址是否已注册为成员
    mapping(address => bool) public registeredMembers;
    
    // 映射：记录每个地址在合约中的余额
    mapping(address => uint256) balance;

    // 状态变量
    mapping(address => uint256) public lastWithdrawTime; // 记录上次取款时间
    uint256 public constant COOLDOWN_PERIOD = 1 days;   // 取款冷却时间：24小时

    struct WithdrawalRequest {
        uint256 amount;
        bool isPending;
    }
    mapping(address => WithdrawalRequest) public pendingRequests; // 审批队列


    // 构造函数 (Constructor) 
    // 仅在合约部署时运行一次
constructor() {
        bankManager = msg.sender;
        // 初始部署时将管理员设为成员
        registeredMembers[msg.sender] = true;
        members.push(msg.sender);
    }

    //  修饰符 (Modifiers) 
    
    // 权限检查：确保调用者必须是管理员
    modifier onlyBankManager() {
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _; // 继续执行被修饰的函数体
    }

    // 权限检查：确保调用者必须是已注册成员
    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }
  
    //  核心功能函数 

    /**
     * @dev 添加新成员
     * 只有管理员可以调用。会检查地址有效性、是否为重复注册。
     */
    function addMembers(address _member) public onlyBankManager {
        require(_member != address(0), "Invalid address");
        require(_member != bankManager, "Bank Manager is already a member");
        require(!registeredMembers[_member], "Member already registered");
        
        registeredMembers[_member] = true; // 在映射中标记
        members.push(_member);            // 存入数组方便遍历
    }

    /**
     * @dev 返回所有成员列表
     */
    function getMembers() public view returns(address[] memory) {
        return members;
    }
    
    /**
     * @dev 存入以太币 (ETH)
     * 使用 payable 关键字允许函数接收 ETH。
     * 只有注册成员可以存钱。
     */
    function depositAmountEther() public payable onlyRegisteredMember {  
        require(msg.value > 0, "Invalid amount"); // 确保发送的金额大于 0
        balance[msg.sender] = balance[msg.sender] + msg.value; // 更新账本余额
    }
    

// 附加作业：
/// --- 1. 提现申请 (带冷却期限制) ---
    function requestWithdrawal(uint256 _amount) public onlyRegisteredMember {
        require(_amount > 0 && balance[msg.sender] >= _amount, "Invalid amount");
        // 检查冷却时间
        require(block.timestamp >= lastWithdrawTime[msg.sender] + COOLDOWN_PERIOD, "In cooldown period");
        
        pendingRequests[msg.sender] = WithdrawalRequest(_amount, true);
    }

    // --- 2. 管理员审批并转账 ---
    /**
     * @dev 管理员审批通过后，合约才会真正把 ETH 发送给用户
     */
    function approveWithdrawal(address _member) public onlyBankManager {
        WithdrawalRequest storage request = pendingRequests[_member];
        require(request.isPending, "No pending request");
        require(balance[_member] >= request.amount, "Member balance changed");

        uint256 amountToTransfer = request.amount;
        
        // 状态更新在前（防止重入攻击）
        balance[_member] -= amountToTransfer;
        request.isPending = false;
        lastWithdrawTime[_member] = block.timestamp;

        // 实际转账操作
        (bool success, ) = payable(_member).call{value: amountToTransfer}("");
        require(success, "Transfer failed");
    }



    /**
     * @dev 查询指定成员的余额
     */
    function getBalance(address _member) public view returns (uint256) {
        require(_member != address(0), "Invalid address");
        return balance[_member];
    } 
}
