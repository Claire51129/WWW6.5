
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;

    // Reentrancy lock setup
    uint256 private _status; // 可重入锁的检查
    uint256 private constant _NOT_ENTERED = 1;  // 表示未被占用
    uint256 private constant _ENTERED = 2;  // 已占用

    constructor() {
        _status = _NOT_ENTERED;  //初始化时，设置为可用状体
    }

    // Custom nonReentrant modifier — locks the function during execution
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;  // 上锁
        _; // 函数执行逻辑，执行后释放锁状态
        _status = _NOT_ENTERED;  // 解锁
    }

    // 存入金额
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    // 提取金额
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;  // 先发送ETH再减余额，那么在发送余额的期间，如果用户多次调用该函数，可能导致我们的合约金库被掏空
    }

    // 安全提取的方法
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}


/**
知识点：
1. 在发送ETH之前更新余额状态
2. 使用nonreentrant锁进行保护

Q：
不过为什么这个锁的粒度这么粗？是一个全局的锁呢，那岂不是最多只能有一个用户在调用该函数

Checks-Effects-Interactions（检查-状态变更-交互）

 */