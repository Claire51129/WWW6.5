// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 一个简单的“插件注册 + 调用”系统
// 用户可以：
// 1. 设置个人资料
// 2. 注册插件（key => 合约地址）
// 3. 通过低级调用执行插件逻辑
contract PluginStore {

    // 用户个人资料结构
    struct PlayerProfile {
        string name;    // 用户名
        string avatar;  // 头像（可以是URL或IPFS地址）
    }

    // 用户地址 => 用户资料
    mapping(address => PlayerProfile) public profiles;

    // 插件标识（字符串key） => 插件合约地址
    mapping(string => address) public plugins;

    // 设置调用者自己的个人资料
    function setProfile(string memory _name, string memory _avatar) external {
        // 直接覆盖当前用户资料
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 获取某个用户的资料
    function getProfile(address user)
        external
        view
        returns (string memory, string memory)
    {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // 注册插件
    function registerPlugin(string memory key, address pluginAddress) external {
        // 没有限制权限，任何人都可以覆盖
        plugins[key] = pluginAddress;
    }

    // 查询插件地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // 调用插件（会修改状态）
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];

        // 确保插件已注册
        require(plugin != address(0), "Plugin not registered");

        // 编码函数调用数据，例如: "setData(address,string)"
        bytes memory data =
            abi.encodeWithSignature(functionSignature, user, argument);

        // 使用低级 call 调用插件
        (bool success, ) = plugin.call(data);

        require(success, "Plugin execution failed");
    }

    // 调用插件,只读，不修改状态
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {

        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");

        // 编码函数调用数据
        bytes memory data =
            abi.encodeWithSignature(functionSignature, user);

        // 使用 staticcall,只读调用，更安全
        (bool success, bytes memory result) =
            plugin.staticcall(data);

        require(success, "Plugin execution failed");

        // 解码返回值（这里假设插件返回 string）
        return abi.decode(result, (string));
    }
}