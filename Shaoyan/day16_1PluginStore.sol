// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    // 玩家配置文件
    struct PlayerProfile {
        string name;
        string avatar;
    }
    
    // 状态变量
    mapping(address => PlayerProfile) public profiles;
    mapping(string => address) public plugins;
    
    // 设置配置文件
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
    }
    
    // 获取配置文件
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }
    
    // 注册插件
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }
    
    // 获取插件地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }
    
    // 运行插件(修改状态) - 使用call
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature(
            functionSignature, 
            user, 
            argument
        );
        
        // 调用插件
        (bool success, ) = plugin.call(data);
        require(success, "Plugin call failed");
    }
    
    // 查询插件(只读) - 使用staticcall
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        
        // 只读调用
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin call failed");
        
        // 解码返回数据
        return abi.decode(result, (string));
    }
}