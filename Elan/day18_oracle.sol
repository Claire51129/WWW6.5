// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Oracle
 * @dev 这是一个简单的预言机合约示例。
 * 它允许授权的数据提供者（Nodes）上传数据，供其他合约查询。
 */
contract Oracle {
    // 权限控制：管理员
    address public owner;

    // 存储数据：数据键(如 "ETH/USDT") => 数据值
    mapping(bytes32 => uint256) private data;
    
    // 记录数据最后更新的时间戳
    mapping(bytes32 => uint256) private lastUpdatedAt;

    // 授权的数据提供者名单
    mapping(address => bool) public authorizedNodes;

    event DataUpdated(bytes32 indexed key, uint256 value, uint256 timestamp);
    event NodeAuthorized(address indexed node, bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorizedNode() {
        require(authorizedNodes[msg.sender] || msg.sender == owner, "Not authorized node");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice 授权或取消授权数据节点
     */
    function setNodeAuthorization(address node, bool status) external onlyOwner {
        authorizedNodes[node] = status;
        emit NodeAuthorized(node, status);
    }

    /**
     * @notice 更新数据（由链外 Node 调用）
     * @param key 数据的唯一标识符（例如：keccak256("BTC/USDT")）
     * @param value 最新的数值
     */
    function updateData(bytes32 key, uint256 value) external onlyAuthorizedNode {
        data[key] = value;
        lastUpdatedAt[key] = block.timestamp;
        
        emit DataUpdated(key, value, block.timestamp);
    }

    /**
     * @notice 获取最新数据
     * @return value 数值
     * @return timestamp 最后更新时间
     */
    function getData(bytes32 key) external view returns (uint256 value, uint256 timestamp) {
        require(lastUpdatedAt[key] > 0, "Data not available");
        return (data[key], lastUpdatedAt[key]);
    }

    /**
     * @notice 辅助函数：将字符串转换为 bytes32 标识符
     */
    function getKey(string calldata name) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(name));
    }
}