// SPDX-Liense-Identifier: MIT
pragma solidity ^0.8.20;

// 导入所有权管理合约（实现权限继承）
import "./day11_Ownable.sol";

/**
 * @title 金库管理合约
 * @dev 支持ETH存款，仅所有者可提款，继承Ownable的权限控制
 */
contract VaultMaster is Ownable {
    // 事件：存款成功（记录存款地址+金额）
    event DepositSuccessful(address indexed account, uint256 value);
    // 事件：提款成功（记录收款地址+金额）
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    /**
     * @dev 查询合约当前ETH余额
     * @return 合约余额（单位：wei）
     */
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    /**
     * @dev 存款函数：任何人可向合约转入ETH
     */
    function deposit() public payable {
        // 校验：存款金额必须>0
        require(msg.value > 0, "Enter a valid amount");
        // 触发事件：记录存款信息
        emit DepositSuccessful(msg.sender, msg.value);
    }

    /**
     * @dev 提款函数：仅所有者可将合约ETH转出到指定地址
     * @param _to 收款地址
     * @param _amount 提款金额（单位：wei）
     */
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        // 校验：提款金额不能超过合约当前余额
        require(_amount <= getBalance(), "Insufficient balance");
        // 调用call发送ETH：返回success状态（忽略剩余返回数据）
        (bool success, ) = payable(_to).call{value: _amount}("");
        // 校验：转账必须成功
        require(success, "Transfer Failed");
        // 触发事件：记录提款信息
        emit WithdrawSuccessful(_to, _amount);
    }
}