// 重入攻击(Reentrancy Attack)——小偷在拿钱的过程中，利用银行[先把钱转出去→再更新余额]的漏洞，再次进来偷钱
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {    //银行作用：存钱+取钱
    mapping(address => uint256) public goldBalance;    //存钱记录：类似账本

    // Reentrancy lock setup 设置防攻击锁（重点）
    uint256 private _status;   //一个“锁”的状态
    uint256 private constant _NOT_ENTERED = 1;    //1=没锁
    uint256 private constant _ENTERED = 2;    //2=已锁

    constructor() {    //构造函数
        _status = _NOT_ENTERED;    // 一开始是没锁
    }

    // （超重点：防盗锁）Custom nonReentrant modifier — locks the function during execution
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");   //如果已锁住，则不让再进
        _status = _ENTERED;   //上锁
        _;    //执行函数内容
        _status = _NOT_ENTERED;   //解锁
    }    //一个函数执行时，别人不能再进来

    // 存钱功能：用户往银行存钱
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");   //必须有钱
        goldBalance[msg.sender] += msg.value;    //更新余额
    }

    // 【重点】漏洞函数：有问题的取钱函数——先转钱，再清余额
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];   //你有多少钱
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");   //先把钱转给你（黑客可利用漏洞执行代码receive）
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;   //最后才清零
    }

    // 安全函数（正确做法）：加防盗锁——先清余额再转钱
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;    //先清零
        (bool sent, ) = msg.sender.call{value: amount}("");    //再转钱
        require(sent, "ETH transfer failed");
    }
}



// 1、重入攻击本质：在函数没执行完之前，再次进入它；
// 2、漏洞原因：先转钱，再改状态(wrong)；
// 3、防御方法：nonReentrant + 先改状态再转钱(correct)。
