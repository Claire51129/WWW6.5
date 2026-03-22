// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 插件商店合约：负责「玩家档案 + 插件调度」
contract PluginStore {
    // 合约拥有者，用于管理插件注册/替换
    address public owner;

    // 玩家信息结构体
    struct PlayerProfile {
        string name;
        string avatar;
    }
    // 玩家信息映射
    mapping(address => PlayerProfile) public profiles;

    // === Multi-plugin support ===
    // 插件映射：key => 插件合约地址
    mapping(string => address) public plugins;

    // 部署时记录 owner，用于演示最基础的权限控制
    constructor() {
        owner = msg.sender;
    }

    // 仅允许 owner 调用的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // ========== Core Profile Logic ==========
    // 设置玩家信息
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 获取玩家信息
    function getProfile(
        address user
    ) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // ========== Plugin Management ==========

    // 注册 / 替换插件
    // 为了贴近真实项目，这里加上 onlyOwner 权限控制
    function registerPlugin(
        string memory key,
        address pluginAddress
    ) external onlyOwner {
        plugins[key] = pluginAddress;
    }

    // 获取插件
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ========== Plugin Execution ==========
    // 运行插件（写操作）
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(
            functionSignature,
            user,
            argument
        );
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }
        
    // 运行插件（只读视图）
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");
        //编码插件调用 abi？？？
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view call failed");
        //解码插件调用
        return abi.decode(result, (string));
    }
}
