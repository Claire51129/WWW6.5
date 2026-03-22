// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
核心合约：PluginStore

作用：
1 管理玩家基础资料（name + avatar）
2 注册插件
3 调用插件
4 查询插件数据
*/

contract PluginStore {

    // 合约管理员（用于控制插件注册）
    address public owner;

    // 构造函数：部署合约时自动执行
    constructor() {
        owner = msg.sender;
    }

    // 只有管理员才能执行的修饰器
    modifier onlyOwner(){
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    /*
    玩家资料结构体
    这里只存储最基础的信息
    */
    struct PlayerProfile{
        string name;     // 玩家名称
        string avatar;   // 玩家头像（URL或字符串）
    }

    /*
    地址 -> 玩家资料

    每个钱包地址对应一个玩家资料
    */
    mapping(address => PlayerProfile) public profiles;

    /*
    插件注册表

    key: 插件名称（例如 "weapon"）
    value: 插件合约地址
    */
    mapping(string => address) public plugins;

    /*
    ================================
    玩家资料管理
    ================================
    */

    // 设置或更新玩家资料
    function setProfile(
        string memory _name,
        string memory _avatar
    ) external {

        // 将玩家资料存储到 mapping
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 查询玩家资料
    function getProfile(address user)
        external
        view
        returns(string memory, string memory)
    {
        // 从存储中读取资料
        PlayerProfile memory profile = profiles[user];

        // 返回名称和头像
        return (profile.name, profile.avatar);
    }

    /*
    ================================
    插件管理
    ================================
    */

    // 注册插件（只有管理员可以注册）
    function registerPlugin(
        string memory key,
        address pluginAddress
    )
        external
        onlyOwner
    {
        plugins[key] = pluginAddress;
    }

    // 获取插件地址
    function getPlugin(string memory key)
        external
        view
        returns(address)
    {
        return plugins[key];
    }

    /*
    ================================
    插件执行（写操作）
    ================================
    */

    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    )
        external
    {
        // 获取插件地址
        address plugin = plugins[key];

        // 确保插件存在
        require(plugin != address(0), "Plugin not registered");

        /*
        abi.encodeWithSignature

        作用：
        把函数签名 + 参数
        编码成低级调用数据
        */

        bytes memory data =
            abi.encodeWithSignature(
                functionSignature,
                user,
                argument
            );

        /*
        call

        调用插件合约
        插件在自己的存储中执行
        */

        (bool success, ) = plugin.call(data);

        require(success, "Plugin execution failed");
    }

    /*
    ================================
    插件执行（只读查询）
    ================================
    */

    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    )
        external
        view
        returns(string memory)
    {
        // 获取插件地址
        address plugin = plugins[key];

        require(plugin != address(0), "Plugin not registered");

        // 编码函数调用数据
        bytes memory data =
            abi.encodeWithSignature(
                functionSignature,
                user
            );

        /*
        staticcall

        只读调用
        不允许修改状态
        */

        (bool success, bytes memory result) =
            plugin.staticcall(data);

        require(success, "Plugin view call failed");

        // 解码返回值
        return abi.decode(result, (string));
    }
}