// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU {
    address public owner;
    mapping(address => bool) public registeredFriends;
    address[] public friendList;
    mapping(address => uint256) public balances;
    
    // 嵌套映射:记录债务关系
    mapping(address => mapping(address => uint256)) public debts;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "Not registered");
        _;
    }
    
    // 添加朋友
    function addFriend(address _friend) public onlyOwner {
        require(!registeredFriends[_friend], "Already registered");
        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }
    
    // 存入ETH到钱包
    function depositIntoWallet() public payable onlyRegistered {
        balances[msg.sender] += msg.value;
    }
    
    // 记录债务(谁欠谁多少钱)
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        debts[_debtor][msg.sender] += _amount;
    }
    
    // 从钱包支付债务
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(debts[msg.sender][_creditor] >= _amount, "No debt to pay");
        
        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }
    
    // 使用transfer转账
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
    
    // 使用call转账(推荐)
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }
    
    // 提取余额
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }
}