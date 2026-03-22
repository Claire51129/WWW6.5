// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//call调用，在被调用合约中运行
//delegatecall调用，在现在合约中运行
//staticcall，只读，在被调用合约中运行

contract PluginStore 
{
    struct PlayerProfile 
    {
        string name;
        string avatar;
    }

    mapping(address => PlayerProfile) public profiles;
    //将每个以太坊地址（玩家）与其 PlayerProfile 关联起来

    mapping(string => address) public plugins;
    //插件注册表,目录

    function setProfile(string memory _name, string memory _avatar) external 
    {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user) external view returns (string memory, string memory) 
    {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    //插件管理功能，key是识别插件名称
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    //返回插件地址，使用其键
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

function runPlugin(
    string memory key,
    string memory functionSignature,
    address user,
    string memory argument
) external {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");

    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    //构建一个低级函数调用
    (bool success, ) = plugin.call(data);//低级 call 将请求发送到插件合约
    require(success, "Plugin execution failed");
}

function runPluginView(
    string memory key,
    string memory functionSignature,
    address user
) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");

    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    (bool success, bytes memory result) = plugin.staticcall(data);
    //与 call 不同，staticcall  不能改变状态  — 它是只读的
    require(success, "Plugin view call failed");

    return abi.decode(result, (string));
}

}
