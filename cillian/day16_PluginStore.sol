// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {

    // 玩家个人资料结构体
    struct PlayerProfile {
        string name;   // 玩家昵称
        string avatar; // 玩家头像链接或哈希
    }

    // 映射：存储玩家地址与其资料的对应关系
    mapping(address => PlayerProfile) public profiles;
    
    // 映射：存储插件名称（如 "weapon"）与其合约地址的对应关系
    mapping(string => address) public plugins;

    // 设置调用者（msg.sender）自己的个人资料
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 获取指定用户的个人资料（只读）
    function getProfile(address user) external view returns(string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return(profile.name, profile.avatar);
    }

    // 注册或更新插件：关联一个字符串名称（key）到一个合约地址
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    // 查询指定名称的插件地址
    function getPlugin(string memory key) external view returns(address) {
        return plugins[key];
    }

    function runPlugin(string memory key, string memory functionSignature, address user, string memory argument) external {
        // 1. 获取对应的插件地址
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        // 2. 将函数签名和参数进行 ABI 编码
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        
        // 3. 使用底层的 call 执行远程合约调用
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }

    function runPluginView(string memory key, string memory functionSignature, address user) external view returns(string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");
        
        // 1. 将函数签名和参数进行 ABI 编码
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        
        // 2. 使用 staticcall 进行只读调用（确保安全性，防止状态被修改）
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin execution failed");
        
        // 3. 将返回的二进制数据解码为字符串并返回
        return abi.decode(result, (string));
    }
}