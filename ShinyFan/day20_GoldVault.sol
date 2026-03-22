// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;

    //重入锁
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;//函数当前未被使用——可以使用
    uint256 private constant _ENTERED = 2;//已经有人在使用这个函数——阻止再次使用！
    //保证只能进一次

    //构造函数 设置重入状态初始为 _NOT_ENTERED
    constructor() {
        _status = _NOT_ENTERED;
    }

    //修饰符-锁门者
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");//检查是否有人在使用，有人在使用返回“已被锁住”
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    //发送ETH
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    //出错点，在更新用户余额前先给用户发送了ETH
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];//检查用户余额
        require(amount > 0, "Nothing to withdraw");//保证用户有余额

        (bool sent, ) = msg.sender.call{value: amount}("");//把ETH转给用户
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;//最后才把余额清零
    }

    //安全版本的withdraw
    function safeWithdraw() external nonReentrant {//增加修饰符nonReentrant，如果有人在调用函数，其他人就无法进入
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        //先将用户的余额改为零
        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}