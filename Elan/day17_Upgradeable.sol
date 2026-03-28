// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title UpgradeHub
 * @dev 负责管理多个合约的逻辑版本和升级权限。
 * 它通常作为代理合约（Proxy）的后端，存储最新的逻辑实现地址。
 */
contract UpgradeHub {
    // 权限控制：管理员
    address public admin;

    // 记录合约名称到其逻辑地址的映射：keccak256(contractName) => implementationAddress
    mapping(bytes32 => address) private implementations;

    // 记录版本历史：contractName => 地址列表
    mapping(bytes32 => address[]) private versionHistory;

    event Upgraded(bytes32 indexed contractId, address indexed newImplementation);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "UpgradeHub: Caller is not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice 设置或升级某个合约的实现地址
     * @param contractName 合约名称字符串（如 "Vault", "Token"）
     * @param newImplementation 新的逻辑合约地址
     */
    function upgrade(string calldata contractName, address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "UpgradeHub: Invalid address");
        require(newImplementation.code.length > 0, "UpgradeHub: Not a contract");

        bytes32 contractId = keccak256(abi.encodePacked(contractName));
        
        // 更新当前实现
        implementations[contractId] = newImplementation;
        
        // 记录到历史版本中
        versionHistory[contractId].push(newImplementation);

        emit Upgraded(contractId, newImplementation);
    }

    /**
     * @notice 获取指定合约当前的逻辑地址
     */
    function getImplementation(string calldata contractName) external view returns (address) {
        bytes32 contractId = keccak256(abi.encodePacked(contractName));
        address impl = implementations[contractId];
        require(impl != address(0), "UpgradeHub: Contract not registered");
        return impl;
    }

    /**
     * @notice 获取某个合约的历史版本数量
     */
    function getVersionCount(string calldata contractName) external view returns (uint256) {
        bytes32 contractId = keccak256(abi.encodePacked(contractName));
        return versionHistory[contractId].length;
    }

    /**
     * @notice 获取特定版本的地址
     */
    function getVersionAt(string calldata contractName, uint256 index) external view returns (address) {
        bytes32 contractId = keccak256(abi.encodePacked(contractName));
        return versionHistory[contractId][index];
    }

    /**
     * @notice 转移管理员权限
     */
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "UpgradeHub: New admin is zero address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin; 
} 
}