// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeDeposit {
    // 1. 核心账本：记录每个地址在合约里存了多少 ETH (单位是 Wei)
    mapping(address => uint256) public balances;

    // 事件：存款和取款时记录日志
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // 2. 存款功能：将发送的 ETH 记入发送者的账下
    // 必须有 payable 关键字才能接收 ETH
    function deposit() public payable {
        require(msg.value > 0, "Cannot deposit 0 ETH");
        
        // 关键逻辑：在账本里给调用者增加对应的金额
        balances[msg.sender] += msg.value;
        
        emit Deposited(msg.sender, msg.value);
    }

    // 3. 取款功能：用户取回自己的钱
    function withdraw(uint256 _amount) public {
        // 检查 1：账本里有没有这么多钱？
        require(balances[msg.sender] >= _amount, "Insufficient balance in deposit");
        
        // 逻辑顺序：先减账本，再发钱（防止重入攻击的好习惯）
        balances[msg.sender] -= _amount;
        
        // 执行转账：将 ETH 发还给调用者
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, _amount);
    }

    // 4. 查看合约里总共有多少钱
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}