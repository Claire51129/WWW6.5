// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GoldVault {

    uint256 public constant MAX_DEPOSIT = 10 ether;

    mapping(address => uint256) public goldBalance;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, bool safe);

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
        require(msg.value > 0, "Deposit amount must be positive");
        require(
            goldBalance[msg.sender] + msg.value <= MAX_DEPOSIT,
            "Exceeds per-user deposit limit of 10 ETH"
        );
        goldBalance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount, false);
    }
    
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount, true);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
