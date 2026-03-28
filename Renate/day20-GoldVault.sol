// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// GoldVault - 金库合约
// 演示重入攻击漏洞及其防护措施
// 包含一个有漏洞的提款函数和一个安全的提款函数
contract GoldVault {
    // 存储每个用户的黄金（ETH）余额
    mapping(address => uint256) public goldBalance;

    // 重入锁状态变量
    // _NOT_ENTERED = 1: 未锁定状态
    // _ENTERED = 2: 锁定状态（防止重入）
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // 构造函数 - 初始化重入锁状态
    constructor() {
        _status = _NOT_ENTERED;
    }

    // 自定义 nonReentrant 修饰符 - 防止重入攻击
    // 在函数执行期间锁定合约，防止递归调用
    modifier nonReentrant() {
        // 检查合约未处于锁定状态
        require(_status != _ENTERED, "Reentrant call blocked");

        // 锁定合约
        _status = _ENTERED;

        // 执行被修饰的函数
        _;

        // 解锁合约
        _status = _NOT_ENTERED;
    }

    // 存款函数
    // 用户存入 ETH，增加其余额
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    // 有漏洞的提款函数 - 演示重入攻击风险
    // 漏洞: 先发送 ETH，后更新余额
    // 攻击者可以在接收 ETH 时回调此函数，重复提款
    function vulnerableWithdraw() external {
        // 获取用户余额
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // 漏洞所在: 先发送 ETH（外部调用）
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        // 后更新余额 - 如果外部调用重入，余额还未更新！
        goldBalance[msg.sender] = 0;
    }

    // 安全的提款函数 - 使用重入锁保护
    // 遵循 Checks-Effects-Interactions 模式
    function safeWithdraw() external nonReentrant {
        // 1. Checks: 验证条件
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // 2. Effects: 先更新状态
        goldBalance[msg.sender] = 0;

        // 3. Interactions: 最后进行外部调用
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}

// 安全最佳实践总结:
//
// 1. Checks-Effects-Interactions 模式:
//    - Checks: 首先验证所有条件（require）
//    - Effects: 然后更新合约状态
//    - Interactions: 最后进行外部调用
//
// 2. 重入锁（Reentrancy Guard）:
//    - 使用布尔值或状态变量跟踪执行状态
//    - 在函数执行期间锁定合约
//    - OpenZeppelin 提供了标准实现
//
// 3. 使用 transfer 或 send:
//    - transfer: 2300 gas 限制，更安全但不够灵活
//    - call: 可以指定 gas，更灵活但需要额外保护
//
// 4. 其他防护措施:
//    - 使用 pull 模式代替 push 模式
//    - 限制单次提款金额
//    - 使用多签钱包管理大额资金
//
// 5. 审计和测试:
//    - 使用 Slither、Mythril 等工具进行静态分析
//    - 编写针对重入攻击的测试用例
//    - 进行专业的安全审计
