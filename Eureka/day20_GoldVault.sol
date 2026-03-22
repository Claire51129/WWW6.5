// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GoldVault 
{
    mapping(address => uint256) public goldBalance;//存款账户

    //重入锁设置 Reentrancy lock setup
    uint256 private _status;//私有变量，用来告诉我们敏感函数（如 safeWithdraw）是否正在被执行
    uint256 private constant _NOT_ENTERED = 1;//函数当前未被使用——可以使用
    uint256 private constant _ENTERED = 2;//已经有人在使用这个函数——阻止再次使用

    constructor() 
    {
        _status = _NOT_ENTERED;//重入锁初始状态
    }

    //nonReentrant重入锁修饰符
    modifier nonReentrant() 
    {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;//上锁
        _;//实际的函数体执行位置， safeWithdraw() 或其它受 nonReentrant 保护的函数
        _status = _NOT_ENTERED;//解锁
    }

    function deposit() external payable 
    {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external //易受到重入攻击
    {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;
    }

    function safeWithdraw() external nonReentrant //重入锁
    {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;//先设置余额为零，再发送ETH
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
    //遵循 “Checks-Effects-Interactions” 模式
}
