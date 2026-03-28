// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor(){
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant(){
        require(_status !=_ENTERED, "Reentrant call blocked");
        _status = _ENTERED;
        _;//挂载函数内容执行
        _status = _NOT_ENTERED;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value:amount}("");
        //.call向改地址发起一个以太坊交互请求，""代表不传递任何具体的函数调用数据
        //msg.sender合约地址的receive()函数在接收ETH被触发，再次调用vulnerableWithdraw()
        //以太坊强制逻辑 合约收到ETH 对方没有指定哪个函数""，接收方合约启动应急响应，第一选择receive()，第二选择fallback()
        //transfer限制只给接收方2300Gas只够接收方写个日志，不够跑再次调用合约的代码，业界更倾向于用.call+防重入保护
        require(sent, "ETH transfer failed");
        goldBalance[msg.sender] = 0;
    }

    function saftWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;
        (bool sent, )=msg.sender.call{value:amount}("");
        require(sent, "ETH transfer failed");
    }
}