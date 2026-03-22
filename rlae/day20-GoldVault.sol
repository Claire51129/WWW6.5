
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    //第一次调用尚未结束前再次进入同一个函数-Reentrancy（重入）
    mapping(address => uint256) public goldBalance; //每个用户在金库中存了多少 ETH（即黄金）
    uint256 private _status; //私有变量->敏感函数（如 safeWithdraw）是否正在被执
    uint256 private constant _NOT_ENTERED = 1; //函数当前未被使用——可以使用
    uint256 private constant _ENTERED = 2; //已经有人在使用这个函数——阻止再次使用！
    //if 1, change status to 2, after work revert to 2, 在我们的 nonReentrant 修饰符中被激活
    constructor() {
    _status = _NOT_ENTERED; //合约部署时，处于 _NOT_ENTERED 状态
    }
    modifier nonReentrant() {
    require(_status != _ENTERED, "Reentrant call blocked"); //如果 _status 已经是 _ENTERED，说明另一次调用正在进行中
    _status = _ENTERED; //将函数状态标记为“被调用”
    _; //Solidity 会在执行时把 _ 替换为函数代码(无论是 safeWithdraw() 还是其它受 nonReentrant 保护的函数)
    _status = _NOT_ENTERED; //finished =>解锁
    }
    function deposit() external payable {
    require(msg.value > 0, "Deposit must be more than 0");
    goldBalance[msg.sender] += msg.value;
    } //deposit money from user
    function vulnerableWithdraw() external {
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing to withdraw");

    (bool sent, ) = msg.sender.call{value: amount}("");//发送 ETH
    //如果 msg.sender 是一个合约地址,它的 receive() 函数会在接收 ETH 时被触发, 在那个 receive() 函数中会自动调用 vulnerableWithdraw()
    //攻击者的余额看起来依然显示为 1 ETH
    require(sent, "ETH transfer failed");

    goldBalance[msg.sender] = 0; //把用户余额设为 0
    }
    function safeWithdraw() external nonReentrant {// nonReentrant 修饰符，作为额外的防线。
    //- 一旦有人进入函数，就**锁住函数,如果同一地址（或任何外部合约）试图再次调用——即使通过fallback回退函数——也会立即被阻止.函数执行完毕后解锁
    uint256 amount = goldBalance[msg.sender];
    require(amount > 0, "Nothing to withdraw");
    goldBalance[msg.sender] = 0; //在发送 ETH 之前更新余额状态
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "ETH transfer failed");
    //Checks-Effects-Interactions
    //Check（检查条件）
    //Effect（改变状态）
    //Interaction（与外部合约交互）
}


}