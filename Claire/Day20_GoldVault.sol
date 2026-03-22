// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.19;
// 指定Solidity编译器版本

contract GoldVault {
// 定义一个合约，叫"金库"
// 作用：存储ETH，演示重入攻击和防护

    mapping(address => uint256) public goldBalance;
    // 映射：地址 → 存款余额
    // 记录每个地址在金库里存了多少ETH

    // Reentrancy lock setup
    // 重入锁设置
    
    uint256 private _status;
    // 状态锁变量（私有）
    // 1 = 未进入，2 = 已进入
    
    uint256 private constant _NOT_ENTERED = 1;
    // 常量：未进入状态（1）
    
    uint256 private constant _ENTERED = 2;
    // 常量：已进入状态（2）

    constructor() {
        _status = _NOT_ENTERED;
        // 构造函数：初始状态设为"未进入"
    }

    // Custom nonReentrant modifier — locks the function during execution
    // 自定义非重入修饰符 — 函数执行期间锁定
    
    modifier nonReentrant() {
    // 修饰符：防止重入攻击
        
        require(_status != _ENTERED, "Reentrant call blocked");
        // 检查：当前不是"已进入"状态
        // 如果已经是2，说明正在执行中，不允许再进入
        
        _status = _ENTERED;
        // 设置为"已进入"状态，锁定
        
        _;
        // 执行原函数
        
        _status = _NOT_ENTERED;
        // 函数执行完毕，解锁
    }

    function deposit() external payable {
    // 函数：存款
    // external payable：外部调用，可以附带ETH
        
        require(msg.value > 0, "Deposit must be more than 0");
        // 检查：存款金额必须大于0
        
        goldBalance[msg.sender] += msg.value;
        // 增加调用者的黄金余额
    }

    function vulnerableWithdraw() external {
    // ⚠️ 危险函数：容易受到重入攻击的取款函数
    // 这是演示用的"不安全"版本
        
        uint256 amount = goldBalance[msg.sender];
        // 获取调用者的余额
        
        require(amount > 0, "Nothing to withdraw");
        // 检查：余额必须大于0

        (bool sent, ) = msg.sender.call{value: amount}("");
        // ❌ 危险操作：先发送ETH
        // 这里先转账，后更新余额
        // 如果接收者是恶意合约，会在收到ETH时再次调用这个函数
        
        require(sent, "ETH transfer failed");
        // 确保转账成功

        goldBalance[msg.sender] = 0;
        // ❌ 危险：后更新余额
        // 如果接收者在转账时回调这个函数，此时余额还没清零
        // 就能重复提取ETH
    }

    function safeWithdraw() external nonReentrant {
    // ✅ 安全函数：防止重入攻击的取款函数
        
        uint256 amount = goldBalance[msg.sender];
        // 获取调用者的余额
        
        require(amount > 0, "Nothing to withdraw");
        // 检查：余额必须大于0

        goldBalance[msg.sender] = 0;
        // ✅ 安全操作：先更新余额（清零）
        // 即使后续被回调，余额已经是0，无法再次提取
        
        (bool sent, ) = msg.sender.call{value: amount}("");
        // ✅ 安全操作：后发送ETH
        // 此时余额已经是0，即使被回调也拿不到钱了
        
        require(sent, "ETH transfer failed");
        // 确保转账成功
    }
}