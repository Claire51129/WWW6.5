// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    // 玩家配置文件结构体：存储玩家名称和头像
    struct PlayerProfile {
        string name;
        string avatar;
    }
    
    // 状态变量
    mapping(address => PlayerProfile) public profiles;  // 每个地址的档案
    mapping(string => address) public plugins;          // 插件名 -> 插件地址
    
    // 设置自己的配置文件（调用者自动为 msg.sender）
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
    }
    
    // 获取某个用户的配置文件（只读）
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }
    
    // 注册插件：将插件名映射到插件合约地址
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }
    
    // 根据插件名获取插件地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }
    
    // 运行会修改状态的插件函数（使用 call）
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 对函数调用进行 ABI 编码
        bytes memory data = abi.encodeWithSignature(
            functionSignature, 
            user, 
            argument
        );
        
        // 使用 call 调用插件（低层调用）
        (bool success, ) = plugin.call(data);
        require(success, "Plugin call failed");
    }
    
    // 运行只读插件函数（使用 staticcall），并解码返回的字符串
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 编码函数调用（只有一个参数：user）
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        
        // 使用 staticcall 只读调用
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin call failed");
        
        // 解码返回的数据（假设返回一个字符串）
        return abi.decode(result, (string));
    }
}
