
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GoldVault {
    mapping(address => uint256) public goldBalance;
/**当用户调用 `deposit()` 时，Ta们的余额会上升。

当Ta们调用 `withdraw()` 时，余额会下降**/
 
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
/**- `_status` 是一个私有变量，用来告诉我们敏感函数（如 `safeWithdraw`）是否**正在被执行**。
- `_NOT_ENTERED`（值为 `1`）表示：「函数当前未被使用——可以使用」。
- `_ENTERED`（值为 `2`）表示：「已经有人在使用这个函数——阻止再次使用！**/
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call blocked");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;//解锁
    }
/**- 用户把 ETH 发到这个函数。
- 用户余额会增加。
- 合约就持有了用户的资金，直到用户提现为止**/
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be more than 0");
        goldBalance[msg.sender] += msg.value;
    }

    function vulnerableWithdraw() external {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");
//把 ETH 发回给用户
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");

        goldBalance[msg.sender] = 0;
    }
// safeWithdraw() —— 配备 nonReentrant 防护
    function safeWithdraw() external nonReentrant {
        uint256 amount = goldBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        goldBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
}


