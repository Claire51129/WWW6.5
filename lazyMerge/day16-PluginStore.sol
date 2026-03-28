// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    struct PlayerProfile {
        string name;
        string avatar;
    }

    mapping(address => PlayerProfile) public profiles;

    mapping(string => address) public plugins;


    // 设置信息
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    // 查询信息
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }


    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    // 返回插件地址，使用其键
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
        // 确保插件已经注册
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        // 调用插件
        (bool success, ) = plugin.call(data);
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
        require(success, "Plugin view call failed");

        return abi.decode(result, (string));
    }

}


// pluginStore.registerPlugin("weapon", achievementsContractAddress);

//    // 在 PluginStore 外部或内部调用 runPlugin
// pluginStore.runPlugin(
//   "weapon",
//   "setAchievement(address,string)",
//   msg.sender,
//   "Golden Axe"
// );