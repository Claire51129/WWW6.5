// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/**
 * @title SubscriptionStorage
 * @dev 订阅系统的代理合约（Proxy）。
 * 用户所有的交互都发往这个合约，它负责存储数据，并将逻辑委托给 logicContract 执行。
 */
contract SubscriptionStorage is SubscriptionStorageLayout {
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @param _logicContract 初始业务逻辑合约的地址
     */
    constructor(address _logicContract) {
        owner = msg.sender; // 部署者自动成为管理员
        logicContract = _logicContract;
    }

    /**
     * @notice 升级合约逻辑
     * @dev 改变指向的逻辑合约地址，实现“不换地址升级功能”
     * @param _newLogic 新的逻辑合约地址
     */
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    /**
     * @dev 回退函数：当调用本合约中不存在的函数时，会触发此逻辑。
     * 这是代理模式的核心，它利用 delegatecall 将调用转发给逻辑合约。
     */
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");

        // 使用汇编实现底层转发，以节省 Gas 并确保灵活性
        assembly {
            // 1. 将所有的调用数据（calldata）复制到内存的 0 位置
            calldatacopy(0, 0, calldatasize())

            // 2. 执行 delegatecall。
            // 关键点：这会在本合约（Proxy）的上下文（Context）中运行 impl 的代码。
            // 意味着 impl 修改的是本合约的存储变量（如 subscriptions）。
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // 3. 将返回的数据复制到内存的 0 位置
            returndatacopy(0, 0, returndatasize())

            // 4. 根据执行结果判断：0 代表失败（revert），其他代表成功（return）
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev 允许合约直接接收以太坊（主币）
     */
    receive() external payable {}
}