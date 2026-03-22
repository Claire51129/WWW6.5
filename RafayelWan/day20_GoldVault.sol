// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GoldVault {
    // 记录每个人存了多少钱
    mapping(address => uint256) public goldBalance;

    // 重入锁：防止反复调用
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor() {
        _status = _NOT_ENTERED; // 初始状态：门开着
    }

    // 锁修饰器：调用函数时锁门，结束后开门
    modifier nonReentrant() {
        require(_status != _ENTERED, "No reentrant calls!");
        _status = _ENTERED; // 锁门
        _; // 执行函数内容
        _status = _NOT_ENTERED; // 开门
    }

    // 存钱：往存钱罐放钱
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0!");
        goldBalance[msg.sender] += msg.value;
    }

    // 【有漏洞的取钱】先给钱，后改余额
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw!");

        // 先转钱！坏人会在这里反复喊取钱
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed!");

        // 后改余额！太晚了，坏人已经偷了很多次
        goldBalance[msg.sender] = 0;
    }

    // 【安全的取钱】先改余额，后转钱，还加锁
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw!");

        // 先改余额！本子先擦干净
        goldBalance[msg.sender] = 0;

        // 再转钱！而且有锁，不能反复进来
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed!");
    }
}