// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 所有权管理合约
 * @dev 实现「仅所有者可操作」的权限控制与所有权转移
 */
contract Ownable {
    // 私有变量：存储当前所有者地址（仅合约内部可直接访问）
    address private owner;

    // 事件：记录所有权转移（原所有者 → 新所有者）
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev 构造函数：部署时将「部署者」设为初始所有者
     */
    constructor() {
        owner = msg.sender;
        // 触发事件：从「0地址（无主状态）」转移到部署者
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev 修饰器：限制仅所有者可调用后续函数
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _; // 执行被修饰函数的逻辑
    }

    /**
     * @dev 查询当前所有者地址
     * @return 所有者地址
     */
    function ownerAddress() public view returns (address) {
        return owner;
    }

    /**
     * @dev 转移所有权（仅所有者可调用）
     * @param _newOwner 新所有者地址
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        // 校验：新地址不能是无效的0地址
        require(_newOwner != address(0), "Invalid address");
        address previous = owner;
        owner = _newOwner;
        // 触发事件：记录所有权变更
        emit OwnershipTransferred(previous, _newOwner);
    }
}