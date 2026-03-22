// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 插件商店合约 - 一个可扩展的模块化系统
// 核心思想：主合约不写死所有功能，而是通过注册"插件"来动态扩展
// 类比：手机本身只有基础功能，通过安装 App（插件）来增加新能力
contract PluginStore {

    // 玩家配置文件结构体
    struct PlayerProfile {
        string name;    // 玩家名称
        string avatar;  // 玩家头像（URL 或标识符）
    }

    // 状态变量
    // 地址 => 玩家配置文件（每个用户一份档案）
    mapping(address => PlayerProfile) public profiles;
    // 插件名称 => 插件合约地址（通过名字找到对应的插件合约）
    // 类比：App Store 里 "微信" => 对应的安装包地址
    mapping(string => address) public plugins;

    // 设置配置文件 - 用户填写自己的名称和头像
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
    }

    // 获取配置文件 - 查询某个用户的名称和头像
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // 注册插件 - 把一个插件合约的地址登记到商店里
    // 例如：registerPlugin("greeting", 0x1234...) 注册一个叫"greeting"的插件
    // 之后就可以通过名字 "greeting" 找到并调用这个插件
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    // 获取插件地址 - 通过插件名查询对应的合约地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // 运行插件（可修改状态）- 使用 call
    // 这是整个合约最核心的函数：通过名字找到插件，动态调用插件的函数
    function runPlugin(
        string memory key,                  // 插件名称（用来查找插件地址）
        string memory functionSignature,     // 要调用的函数签名，如 "greet(address,string)"
        address user,                        // 传给插件函数的第一个参数：用户地址
        string memory argument               // 传给插件函数的第二个参数：字符串参数
    ) external {
        // 通过名字查找插件合约地址
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found"); // 插件必须已注册

        // abi.encodeWithSignature：把函数名和参数编码成 EVM 能理解的字节数据
        // 类比：把"调用 greet 函数，参数是 0xABC 和 hello"翻译成机器语言
        bytes memory data = abi.encodeWithSignature(
            functionSignature,
            user,
            argument
        );

        // call：向插件合约发送调用请求
        (bool success, ) = plugin.call(data);
        require(success, "Plugin call failed"); // 调用失败则回滚

        // 注意：这里没有用返回值，只关心调用是否成功
    }

    // 查询插件（只读）- 使用 staticcall
    // 和 runPlugin 类似，但只能读取数据，不能修改任何状态
    function runPluginView(
        string memory key,                  // 插件名称
        string memory functionSignature,     // 函数签名，如 "getTitle(address)"
        address user                         // 用户地址
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not found");

        // 编码函数调用（和上面一样）
        bytes memory data = abi.encodeWithSignature(functionSignature, user);

        // staticcall：和 call 的区别是它保证不会修改任何链上状态
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin call failed");

        // abi.decode：把返回的字节数据解码回 string 类型
        // 和 abi.encodeWithSignature 是一对：encode 是编码发送，decode 是解码接收
        return abi.decode(result, (string));
    }
}