// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GoldVault {
    mapping(address => uint256) public goldBalance;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");
        goldBalance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // ❌ 漏洞版本（用于攻击）
    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        goldBalance[msg.sender] = 0;
        emit Withdrawal(msg.sender, amount);
    }

    // ✅ 安全版本（CEI模式）
    function safeWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance");

        goldBalance[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    // ✅ 安全版本（重入锁）
    function guardedWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "No balance");

        goldBalance[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}