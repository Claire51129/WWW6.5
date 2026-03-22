// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 以太小猪存钱罐 (EtherPiggyBank)
 * @author 自定义作者名
 * @notice 这是一个简单的ETH存钱罐合约，支持管理员管理成员、成员存款/取款、查询余额
 * @dev 包含权限管理、ETH处理、账本记录核心逻辑
 */
contract EtherPiggyBank {

    // --- 状态变量 (存储在区块链上) ---
    
    // 银行管理员地址
    address public bankManager;
    
    // 存储所有成员地址的数组（私有，仅内部/通过函数访问）
    address[] private members;
    
    // 映射：记录地址是否已注册
    mapping(address => bool) public registeredMembers;
    
    // 映射：记录每个成员的ETH余额（修复拼写错误：balance → balances）
    mapping(address => uint256) public balances;

    // --- 构造函数 (部署合约时仅运行一次) ---
    constructor() {
        bankManager = msg.sender; // 部署者为初始管理员
        registeredMembers[msg.sender] = true; // 管理员标记为已注册（补充：原代码漏了这行）
        members.push(msg.sender); // 管理员加入成员列表
    }

    // --- 权限修饰器 ---
    modifier onlyBankManager(){
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }

    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }

    // --- 核心功能函数 ---
    /**
     * @notice 添加新成员（仅管理员可操作）
     * @param _member 待添加的成员地址
     */
    function addMembers(address _member) public onlyBankManager {
        require(_member != address(0), "Invalid address"); // 禁止零地址
        require(!registeredMembers[_member], "Member already registered"); // 禁止重复添加
        
        registeredMembers[_member] = true;
        members.push(_member);
    }

    /**
     * @notice 获取所有成员列表
     * @return 成员地址数组
     */
    function getMembers() public view returns(address[] memory){
        return members;
    }

    /**
     * @notice 成员存款（修复：移除冗余的_amount参数，直接使用msg.value）
     * @dev payable修饰符允许函数接收ETH，余额直接累加msg.value
     */
    function depositEther() public payable onlyRegisteredMember {
        require(msg.value > 0, "Invalid amount: must send > 0 ETH"); // 校验存款金额>0
        balances[msg.sender] += msg.value; // 修复变量名：balance → balances
    }

    /**
     * @notice 成员取款（模拟，仅账本扣减，未实际转账ETH）
     * @param _amount 取款金额（单位：wei）
     */
    function withdraw(uint256 _amount) public onlyRegisteredMember {
        require(_amount > 0, "Invalid amount: must withdraw > 0"); // 校验取款金额>0
        require(balances[msg.sender] >= _amount, "Insufficient funds"); // 校验余额充足
        
        balances[msg.sender] -= _amount; // 修复变量名：balance → balances
    }

    /**
     * @notice 查询指定成员的余额（修复逻辑：返回指定_member的余额，而非调用者）
     * @param _member 待查询的成员地址
     * @return 该成员的ETH余额（单位：wei）
     */
    function getBalance(address _member) public view returns(uint256) {
        require(_member != address(0), "Invalid address"); // 禁止查询零地址
        return balances[_member]; // 修复：1.变量名 2.返回指定_member的余额
    }
}