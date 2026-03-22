// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 模块化游戏系统
contract PluginStore {

    // 玩家资料
    // 结构体耗费gas，永久存储在链上，安全且不可篡改的数据结构
    //对象 前端临时的数据，内存数据库中，临时可修改
    struct PlayerProfile {
        string name;
        string avatar;//头像
    }
// 地址与玩家数据对应--》文件
    mapping(address => PlayerProfile) public profiles;

    // 插件目录，对应不同的合约地址
    mapping(string => address) public plugins;

    // ========== Core Profile Logic ==========
// 存储名字 头像
    function setProfile(string memory _name, string memory _avatar) external {
        // 结构体实例直接用就好了
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }
// 允许  任何人  使用钱包地址查询玩家的个人资料
    function getProfile(address user) external view returns (string memory, string memory) {
    //    玩家文件 是PlayerProfile类型的，key是地址
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // ========== 插件管理 ==========
// 插件key对应的地址为pluginAddress，注册插件--》插件名字和地址
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }
// 返回插件地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ========== Plugin Execution ==========
//难！！！
function runPlugin(
    string memory key,
    string memory functionSignature,
    address user,
    string memory argument
) external {
    address plugin = plugins[key];//插件地址
    //plugin 如果 key 不存在，默认返回 address(0)
    require(plugin != address(0), "Plugin not registered");//确保插件以及注册了
// abi.encodeWithSignature 需要这个签名 会自动去找functionSignature提到的函数，后面是找到的函数需要的参数类型
//   如"setWeapon(address, string)", msg.sender, "Golden Axe"
// abi.encodeWithSignature 只能区分 参数类型，无法区分 同名但参数不同的函数 好厉害！！
// abi.encodeWithSignature = 写一张 密码条，告诉魔法盒子：我要调用哪个小精灵（函数），和它需要什么参数。
    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);//encodeWithSignature会把这些信息转换成密码
    (bool success, ) = plugin.call(data); // 把这个密码发给一个插件合约，plugin--》合约地址就是合约
    require(success, "Plugin execution failed");//插件失败（由于无效参数或逻辑错误），整个交易将回滚
}


// 调用插件合约上的  只读函数  并返回结果。
function runPluginView(
    string memory key,
    string memory functionSignature,
    address user
) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");
// 仅使用用户地址准备函数调用所需的数据
    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    // 与 call 不同，staticcall  不能改变状态  — 它是只读的
    (bool success, bytes memory result) = plugin.staticcall(data);
    require(success, "Plugin view call failed");
// 将返回的字节转换为字符串 
    return abi.decode(result, (string));
}

// pluginStore.runPlugin("weapon", "setWeapon(address, string)", msg.sender, "Golden Axe");
}
