// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 一个简单的“金库”合约，用来演示重入攻击漏洞和防御
contract GoldVault {

    // 记录每个用户存入的ETH余额
    mapping(address => uint256) public goldBalance;

    // ===== 重入锁（Reentrancy Guard） =====

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1; // 未进入
    uint256 private constant _ENTERED = 2;     // 已进入（锁定中）

    constructor() {
        // 初始状态为未锁定
        _status = _NOT_ENTERED;
    }

    // 防重入修饰器
    // 在函数执行期间加锁，防止再次进入（重入）
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");

        _status = _ENTERED; // 上锁

        _; // 执行函数主体

        _status = _NOT_ENTERED; // 解锁
    }

    // 存款函数
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");

        // 增加用户余额
        goldBalance[msg.sender] += msg.value;
    }

    // 存在漏洞的提现函数（可被重入攻击）
    function vulnerableWithdraw() external {

        // 读取用户余额
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        //  问题点：先转账，再更新余额
        // 攻击者在 receive() 中可以再次调用该函数
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        // 在转账之后才清零 → 太晚了（漏洞）
        goldBalance[msg.sender] = 0;
    }

    //  安全提现函数（防重入）
    function safeWithdraw() external nonReentrant {

        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        //  先更新状态（余额清零）
        goldBalance[msg.sender] = 0;

        // 再进行外部调用（转账）
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}