// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;

    // Reentrancy lock setup
    uint256 private _status; // 是一个私有变量，用来告诉我们敏感函数（如 safeWithdraw）是否正在被执行。
    uint256 private constant _NOT_ENTERED = 1; // 「函数当前未被使用——可以使用」
    uint256 private constant _ENTERED = 2; // 「已经有人在使用这个函数——阻止再次使用！」

    constructor() {
        _status = _NOT_ENTERED;
    }

    // Custom nonReentrant modifier — locks the function during execution
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED; // 上锁
        _;
        _status = _NOT_ENTERED; // 解锁（重置锁）
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}(""); // 如果 `msg.sender` 是一个合约地址，它的 `receive()` 函数会在接收 ETH 时被触发。而在那个 `receive()` 函数中，它**再次调用 `vulnerableWithdraw()`**。于是……在我们还未更新用户余额之前，我们又回到了同一个发送ETH的函数内部。
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;
    }

    function safeWithdraw() external nonReentrant { // 第二步修复：nonReentrant 修饰符
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0; // 第一步修复：在发送 ETH 之前更新余额状态。顺序很重要！
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}

/** 
### 遵循 “Checks-Effects-Interactions” 模式

这个函数现在遵循一个**著名的 Solidity 最佳实践**，称为 **Checks-Effects-Interactions（检查-状态变更-交互）** 模式：

1. **Check**（检查条件）   
    `require(amount > 0, "Nothing to withdraw");`
    
2. **Effect**（改变状态）    
    `goldBalance[msg.sender] = 0;`
    
3. **Interaction**（与外部合约交互）    
    `msg.sender.call{value: amount}("");`
    

为什么这个顺序重要：
    当我们与外部世界交互（那是我们无法控制的）时，我们自己的合约状态已经安全更新。
    这避免了一大类漏洞——而不仅仅是重入。
    
 */