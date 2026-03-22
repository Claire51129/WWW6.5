//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// PluginStore - 插件存储合约
// 这是一个插件系统的核心合约，允许注册和调用各种插件
// 支持玩家资料管理和插件的动态调用
contract PluginStore{

    // 玩家资料结构体
    // name: 玩家名称
    // avatar: 玩家头像标识
    struct PlayerProfile{
        string name;
        string avatar;
    }

    // 存储每个地址的玩家资料
    mapping(address =>PlayerProfile) public profiles;

    // 存储已注册的插件
    // key: 插件标识符（字符串）
    // value: 插件合约地址
    mapping(string => address)public plugins;

    // 设置玩家资料
    // _name: 玩家名称
    // _avatar: 玩家头像标识
    function setProfile(string memory _name, string memory _avatar) external{
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 获取玩家资料
    // user: 玩家地址
    // 返回: (名称, 头像)
    function getProfile(address user)external view returns(string memory, string memory){
        PlayerProfile memory profile = profiles[user];
        return(profile.name, profile.avatar);

    }

    // 注册插件
    // key: 插件标识符（如 "weapon", "achievement" 等）
    // pluginAddress: 插件合约地址
    function registerPlugin(string memory key, address pluginAddress)external{
        plugins[key] = pluginAddress;
    }

    // 获取插件地址
    // key: 插件标识符
    // 返回: 插件合约地址
    function getPlugin(string memory key) external view returns(address){
        return plugins[key];
    }

    // 执行插件函数（状态改变）
    // key: 插件标识符
    // functionSignature: 函数签名（如 "setWeapon(address,string)"）
    // user: 用户地址（作为参数传递给插件）
    // argument: 额外参数（如装备名称）
    // 使用 call 调用插件合约，允许执行状态改变操作
    function runPlugin(string memory key, string memory functionSignature, address user,string memory argument) external {
        // 获取插件地址
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        // 编码函数调用数据
        // abi.encodeWithSignature 将函数签名和参数编码为调用数据
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);

        // 使用 low-level call 调用插件合约
        // call 允许执行状态改变操作（写入存储）
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }

    // 执行插件函数（只读视图）
    // key: 插件标识符
    // functionSignature: 函数签名
    // user: 用户地址
    // 返回: 插件返回的字符串数据
    // 使用 staticcall 调用插件合约，保证不修改状态
    function runPluginView(string memory key, string memory functionSignature, address user)external view returns(string memory){
        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");

        // 编码函数调用数据
        bytes memory data = abi.encodeWithSignature(functionSignature, user);

        // 使用 staticcall 调用插件合约
        // staticcall 保证被调用的合约不会修改状态（只读操作）
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin execution failed");

        // 解码返回数据
        return abi.decode(result,(string));
    }
}

// 使用示例:
// pluginStore.runPlugin("weapon", "setWeapon(address, string)", msg.sender, "Golden Axe");
// 这将调用名为 "weapon" 的插件的 setWeapon 函数，为用户装备 "Golden Axe"
