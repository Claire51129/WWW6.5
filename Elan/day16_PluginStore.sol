// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PluginStore
 * @dev 用于管理和存储可用插件的注册表合约。
 * 允许管理员添加插件，并允许用户或合约查询插件信息。
 */
contract PluginStore {
    // 插件结构体
    struct Plugin {
        address implementation; // 插件合约地址
        bytes4[] selectors;    // 该插件提供的函数选择器列表
        bool isActive;         // 插件是否启用
    }

    // 存储所有已注册的插件：插件ID => 插件详情
    mapping(bytes32 => Plugin) public plugins;
    
    // 权限控制：管理员地址
    address public owner;

    event PluginAdded(bytes32 indexed pluginId, address indexed implementation);
    event PluginToggled(bytes32 indexed pluginId, bool newState);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice 注册一个新插件
     * @param pluginId 插件的唯一标识符（通常是名称的哈希）
     * @param implementation 逻辑合约地址
     * @param selectors 该插件包含的函数签名列表
     */
    function addPlugin(
        bytes32 pluginId, 
        address implementation, 
        bytes4[] calldata selectors
    ) external onlyOwner {
        require(implementation != address(0), "Invalid address");
        require(plugins[pluginId].implementation == address(0), "Plugin already exists");

        plugins[pluginId] = Plugin({
            implementation: implementation,
            selectors: selectors,
            isActive: true
        });

        emit PluginAdded(pluginId, implementation);
    }

    /**
     * @notice 启用或禁用插件
     */
    function togglePlugin(bytes32 pluginId) external onlyOwner {
        require(plugins[pluginId].implementation != address(0), "Plugin not found");
        plugins[pluginId].isActive = !plugins[pluginId].isActive;
        
        emit PluginToggled(pluginId, plugins[pluginId].isActive);
    }

    /**
     * @notice 获取插件的所有函数选择器
     */
    function getSelectors(bytes32 pluginId) external view returns (bytes4[] memory) {
        return plugins[pluginId].selectors;
    }

    /**
     * @notice 检查插件是否可用
     */
    function isPluginValid(bytes32 pluginId) external view returns (bool) {
        return plugins[pluginId].implementation != address(0) && plugins[pluginId].isActive;
    }
}