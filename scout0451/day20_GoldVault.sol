// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    //映射记录每个用户在金库中存了多少 ETH
    mapping(address => uint256) public goldBalance;

    // Reentrancy lock setup重入锁系统
    uint256 private _status; //变量告知敏感函数是否正在被执行。
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    //部署合约时初始化为_NOT_ENTERED状态
    constructor() {
        _status = _NOT_ENTERED;
    }

    // Custom nonReentrant modifier — locks the function during execution
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");//检查调用是否正在进行
        _status = _ENTERED;//函数标记被调用
        _;                 //执行函数
        _status = _NOT_ENTERED;//完成后重置
    }

    //存入ETH
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
        //合约把攻击者的余额置为 0 之前就把金库掏空了
        goldBalance[msg.sender] = 0;
    }

    //提现安全版
    //nonReentrant 修饰符
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        //在我们发送任何 ETH 之前执行。这意味着提现一开始我们就把用户余额清零。
        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}

//Checks检查-Effects改变状态-Interactions外部合约交互 模式


