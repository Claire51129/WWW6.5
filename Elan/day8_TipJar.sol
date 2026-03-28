// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    // 1. 状态变量：存储合约拥有者的地址
    address public owner;

    // 2. 事件：当有人打赏时，在区块链上记录日志
    event NewTip(address indexed from, uint256 amount, string message);

    // 3. 构造函数：在部署合约时，将部署者设为 owner
    constructor() {
        owner = msg.sender;
    }

    // 4. 打赏函数：允许任何人发送以太币，并附带一条留言
    // payable 关键字表示该函数可以接收资金
    function sendTip(string memory _message) public payable {
        require(msg.value > 0, "You need to send some ETH!");
        
        // 触发事件
        emit NewTip(msg.sender, msg.value, _message);
    }

    // 5. 提现函数：只有 owner 可以把合约里的钱取走
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw.");
        
        // 将合约当前的全部余额发送给 owner
        payable(owner).transfer(address(this).balance);
    }

    // 获取合约当前余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}