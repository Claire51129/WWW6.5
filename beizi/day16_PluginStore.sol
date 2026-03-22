// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract PluginStore{  //PluginStore 插件商店
    //玩家信息
    struct PlayerProfile {
    string name;
    string avatar;
}
mapping(address => PlayerProfile) public profiles;
mapping(string => address) public plugins;//每一个插件都有一个合约进行编写

//玩家可以修改名字和头像
function setProfile(string memory _name, string memory _avatar) external {
    profiles[msg.sender] = PlayerProfile(_name, _avatar);
}

//user和msg.sender 的意思一样，但是它可以允许任何人使用地址查询玩家的个人资料，而不是当前正在点击按钮的人
function getProfile(address user) external view returns (string memory, string memory) {
    PlayerProfile memory profile = profiles[user]; //我们从存储中获取资料并复制到内存
    return (profile.name, profile.avatar);
}

//注册插件；从现在起，当你听到 "key" 这个名字时，就去 "pluginAddress" 这个地方找对应的功能
function registerPlugin(string memory key, address pluginAddress) external {
    plugins[key] = pluginAddress;
}

//通过插件的人类可读名称（key）来获取其对应的智能合约地址
function getPlugin(string memory key) external view returns (address) {
    return plugins[key];
}

//动态地调用并执行已注册插件中的特定功能
function runPlugin(
    string memory key,
    string memory functionSignature,
    //函数签名就像是函数的“身份证号”它通过 “函数名(参数类型1,参数类型2)” 的格式，让合约能够打破模块之间的壁垒，实现“即插即用”的动态功能调用
    //函数签名是指向插件合约中定义的具体函数

    address user,
    string memory argument//传递给插件的具体数据
) external {
    address plugin = plugins[key];//合约根据你提供的名字（key）去账本里查地址
    require(plugin != address(0), "Plugin not registered");

    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    //abi.encodeWithSignature：这是一个内置的工具函数，可以理解为一个自动打包机
    //bytes：代表打包后的数据是二进制格式，data 就是这个已经封好口、随时可以投递的信封
    (bool success, ) = plugin.call(data);
    require(success, "Plugin execution failed");
}

//像是游戏的*信息显示面板”。它让前端应用能够安全、免费且动态地从各个独立的插件中提取信息并展示给玩家，而不需要把所有复杂的逻辑和数据都挤在主合约里
function runPluginView(
    string memory key,
    string memory functionSignature,
    address user
) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");

    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    (bool success, bytes memory result) = plugin.staticcall(data); //与 call 不同，staticcall不能改变状态，用于以只读方式与外部插件合约进行交互
    require(success, "Plugin view call failed");

    return abi.decode(result, (string));
}

//runPlugin = 动作执行者。它让插件去“记录”或“更新”玩家的游戏行为和数据
//runPluginView = 数据搬运工。它把插件里记录好的数据“读出来”给玩家或前端界面看


}
