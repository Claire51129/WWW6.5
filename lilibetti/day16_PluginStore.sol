//来定义一个玩家们的资料中心

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    struct PlayerProfile {
        string name;
        string avatar;
    }

    mapping(address => PlayerProfile) public profiles;

    mapping(string => address) public plugins; //插件来了

// 玩家可以创建or更新个人资料
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

//谁都可以看你的资料
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

//插件也来支持了
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

//检查一下
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

//都可以用，很灵活
function runPlugin(
    string memory key,
    string memory functionSignature,
    address user,
    string memory argument
) external {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");
//这一块最关键，abi这个，还要研究下，插旗
    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    (bool success, ) = plugin.call(data); //插旗
    require(success, "Plugin execution failed");
}
//可以用插件了
function runPluginView(
    string memory key,
    string memory functionSignature,
    address user
) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not registered");
//复习=前面的部分是什么含义
    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    (bool success, bytes memory result) = plugin.staticcall(data);
    require(success, "Plugin view call failed");

    return abi.decode(result, (string));
}

}
