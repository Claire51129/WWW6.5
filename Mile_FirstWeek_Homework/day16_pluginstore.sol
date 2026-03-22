// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title day16_PluginStore
 * @dev 模块化智能合约架构 - 插件商店核心
 * 
 * 🌳 核心功能:
 * - 动态加载插件：通过字符串 Key 映射到不同的合约地址
 * - 低级调用：使用 call (写操作) 和 staticcall (读操作) 执行外部逻辑
 * - ABI 编码：动态构建函数调用数据，实现真正的通用接口
 * 
 * ⚠️ 注意: 本合约不包含任何具体的游戏逻辑（如成就或武器），
 * 它只是一个通用的执行环境。
 */
contract day16_PluginStore {
    
    // 玩家核心配置文件 (由主合约直接管理，不依赖插件)
    struct PlayerProfile {
        string name;
        string avatar;
    }
    
    // 状态变量
    mapping(address => PlayerProfile) public profiles;
    mapping(string => address) public plugins;
    
    // 事件
    event PluginRegistered(string key, address pluginAddress);
    event PluginExecuted(string key, bytes4 funcSelector, bool success);

    /**
     * @dev 设置玩家配置文件
     */
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
    }
    
    /**
     * @dev 获取玩家配置文件
     */
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }
    
    /**
     * @dev 注册插件
     * @param key 插件的唯一标识符 (例如: "achievements", "weapons")
     * @param pluginAddress 插件合约的地址
     */
    function registerPlugin(string memory key, address pluginAddress) external {
        require(pluginAddress != address(0), "Invalid plugin address");
        plugins[key] = pluginAddress;
        emit PluginRegistered(key, pluginAddress);
    }
    
    /**
     * @dev 获取插件地址
     */
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }
    
    /**
     * @dev 运行插件 (修改状态) - 使用 .call()
     * 
     * 🔑 原理:
     * 1. 根据 key 找到插件地址。
     * 2. 使用 abi.encodeWithSignature 将函数名和参数编码成 bytes。
     *    格式: [4字节函数选择器][参数1][参数2]...
     * 3. 使用 .call(data) 发送交易。
     *    - .call 允许被调用合约修改其自身的存储状态。
     *    - msg.sender 在插件合约中会变成 PluginStore 的地址。
     * 
     * @param functionSignature 严格的函数签名，如 "setAchievement(address,string)"
     *                          ⚠️ 注意：类型间无空格，uint 必须写为 uint256
     */
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 1. 编码调用数据
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        
        // 2. 执行低级调用 (.call)
        // 返回 (success, resultBytes)，这里我们主要关心 success
        (bool success, ) = plugin.call(data);
        
        require(success, "Plugin execution failed");
        
        emit PluginExecuted(key, bytes4(data), true);
    }
    
    /**
     * @dev 运行插件 (只读查询) - 使用 .staticcall()
     * 
     * 🔑 原理:
     * 1. 同样编码数据。
     * 2. 使用 .staticcall(data)。
     *    - .staticcall 保证不会修改任何状态 (EVM 层面强制限制)。
     *    - 适用于 getter 函数，更安全且 Gas 有时更低。
     * 3. 解码返回的 bytes 数据。
     */
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");
        
        // 1. 编码调用数据 (单参数)
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        
        // 2. 执行静态调用 (.staticcall)
        (bool success, bytes memory result) = plugin.staticcall(data);
        
        require(success, "Plugin view call failed");
        require(result.length > 0, "Empty result from plugin");
        
        // 3. 解码返回值 (假设返回的是 string)
        return abi.decode(result, (string));
    }
}