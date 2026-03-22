// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title GoldVault
 * @dev 黄金金库合约：专门用来演示重入攻击（Reentrancy）的原理与防御。
 */
contract GoldVault {
    // 记录每个用户存入的以太坊余额
    mapping(address => uint256) public goldBalance;

    // --- 重入锁（Reentrancy Lock）状态变量 ---
    // 为什么不直接用 bool？因为在 EVM 中，修改非零值的 Gas 消耗有时比修改零值更稳定（防重排攻击）
    uint256 private _status; 
    uint256 private constant _NOT_ENTERED = 1; // 门开着
    uint256 private constant _ENTERED = 2;     // 门关了

    constructor() {
        _status = _NOT_ENTERED; // 初始状态：允许进入
    }

    /**
     * @dev 自定义防重入修饰符
     * 核心逻辑：函数开始执行前把“门”锁上，执行完再把“门”打开。
     * 如果函数执行期间（控制权在外人手里时）有人想再次进来，require 会直接拦截。
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked"); // 检查锁状态
        _status = _ENTERED;     // 加锁
        _;                      // 执行具体的业务逻辑（如 safeWithdraw）
        _status = _NOT_ENTERED; // 业务跑完，解锁
    }

    /**
     * @notice 存款：任何人都可以存入 ETH
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    /**
     * @notice 【高危函数：存在重入漏洞】
     * @dev 错误原因：违反了 C-E-I 原则。它在“更新余额”之前就“发送了资金”。
     * 当执行到 .call 时，控制权交给了黑客合约，黑客可以趁机再次调用此函数。
     */
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // ！！！致命弱点：发出转账请求。
        // 这会触发接收方的 receive()，如果接收方式黑客合约，它会在这里“回马枪”再次提现。
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        // 这一行在重入发生时根本跑不到，所以用户的余额在黑客看来永远是“没扣钱”的状态。
        goldBalance[msg.sender] = 0;
    }

    /**
     * @notice 【安全函数：双重防御】
     * @dev 防御手段：
     * 1. 使用 nonReentrant 锁：物理隔绝二次进入的可能性。
     * 2. 遵循 C-E-I 原则：先清空账本余额（Effect），再发钱（Interaction）。
     */
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // --- 先修改状态 (Effects) ---
        // 即使没有上面的锁，先扣钱也能防止大部分重入，因为第二次进来时余额已经是 0 了。
        goldBalance[msg.sender] = 0;

        // --- 后进行外部交互 (Interactions) ---
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}