// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//这个合约的设计模式非常类似于微服务架构：
//数据层：PluginStore 合约作为中心化的数据存储，持有所有玩家的 profiles。
//插件层：外部合约（插件）实现具体的游戏逻辑（如背包、等级、任务等）。
//代理层：PluginStore 充当代理，接收请求，然后通过
// .call 触发外部合约的状态变化 .staticcall 将请求转发给具体的插件，用于高效、只读查询 delegatecall 运用插件并将数据存储在主合约中

contract PluginStore {
    struct PlayerProfile {
        string name;//玩家名字
        string avatar;//玩家头像
    }
    
    mapping(address => PlayerProfile) public profiles;
    // === Multi-plugin support插件注册表 ===
    mapping(string => address) public plugins;

    // ========== Core Profile Logic 负责管理玩家的基本数据（增/改/查）==========
    //参数 _name 和 _avatar 被存储在内存中，仅在函数执行期间存在，这比存储在存储区更节省 Gas
    function setProfile(string memory _name, string memory _avatar) 
    external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }
    //外部只读函数，用于查询指定地址玩家的资料
    function getProfile(address user) external view returns (string memory, string memory) {
        //从存储中获取资料并复制到内存
        PlayerProfile memory profile = profiles[user];
        //返回名称和头像，用于在前端或 UI 中显示
        return (profile.name, profile.avatar);
    }

    // ========== Plugin Management 负责管理哪些插件要被注册到系统中==========
    //将插件的 key（如 "inventory" 或 "level"）映射到具体的合约地址
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }
    //外部只读函数，通过插件 Key 获取其合约地址
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ========== Plugin Executiond调用函数执行插件功能，例如更新玩家的武器或成就。==========
function runPlugin(
    string memory key,//要调用的插件标识
    string memory functionSignature,//要调用的函数签名
    address user,//目标玩家地址
    string memory argument//传递给插件的具体参数（字符串）
) external {
    address plugin = plugins[key];
    //确保插件确实已注册
    require(plugin != address(0), "Plugin not registered");
    //从字符串构建一个可调用的低级函数
    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    //向插件合约发送函数调用请求
    (bool success, ) = plugin.call(data);
    require(success, "Plugin execution failed");
}

//========== 调用插件合约上的  只读函数  并返回结果==========
function runPluginView(
    string memory key,
    string memory functionSignature,
    address user
) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");
    //仅使用用户地址准备函数调用所需的数据
    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    //与call不同，staticcall不能改变状态，它是只读的
    (bool success, bytes memory result) = plugin.staticcall(data);
    //如果插件失败（例如，无效地址或错误的签名），调用将被撤销
    require(success, "Plugin view call failed");
    //将返回的字节转换为字符串返回给调用者
    return abi.decode(result, (string));
}

}