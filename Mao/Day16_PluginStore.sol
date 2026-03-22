// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    // 1. 玩家的基础信息（最轻量级的核心数据）
    struct PlayerProfile {
        string name;    // 玩家名字
        string avatar;  // 头像链接
    }
    
    // 存储：地址 => 个人资料
    mapping(address => PlayerProfile) public profiles;
    
    // 存储：插件名称(如 "Achievement") => 插件合约地址
    // 这里的 string 就像是 App 的名字，address 就是 App 的下载链接
    mapping(string => address) public plugins;
    
    // 【功能】修改自己的基础资料
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
    }
    
    // 【功能】查看某人的基础资料
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }
    
    // 【功能】注册新插件（只有管理员或特定逻辑可以增加新功能）
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }
    
    // 【功能】查询某个插件目前的合约地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }
    
    /**
     * @dev 【核心功能】运行插件（会改变区块链状态的操作）
     * @param key 插件的名字
     * @param functionSignature 函数签名，比如 "addExperience(address,uint256)"
     * @param user 要操作的用户地址
     * @param argument 传入的参数（这里简化为了 string）
     */
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found"); // 确保插件已注册
        
        // 【关键步骤 1】编码调用数据
        // 把函数名字和参数打包成一串十六进制字节码，EVM 才能识别
        bytes memory data = abi.encodeWithSignature(
            functionSignature, 
            user, 
            argument
        );
        
        // 【关键步骤 2】发起底层的 .call 调用
        // 这就像是拨通了另一个合约的电话，并把打包好的 data 发送过去
        // success 表示对方执行成功与否
        (bool success, ) = plugin.call(data);
        require(success, "Plugin call failed");
    }
    
    /**
     * @dev 【核心功能】查询插件（只读操作，不会消耗用户 Gas）
     * 使用 staticcall 保证不会意外修改数据
     */
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        
        // 【关键逻辑】.staticcall 专门用于 view 类型的查询
        // 如果插件合约试图在这个调用里修改数据，会直接报错
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin call failed");
        
        // 【关键逻辑】解码返回结果
        // 插件返回的是字节码，需要转换回我们看得懂的 string
        return abi.decode(result, (string));
    }
}