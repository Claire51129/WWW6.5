// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore{
    struct PlayerProfile{
        string name;
        string avatar;
    }

    address public admin;
    mapping (address => PlayerProfile) public profiles;
    mapping (string => address ) public plugins;

    modifier onlyAdmin() {
    require(msg.sender == admin, "Not admin");
    _;
    } 

    event PluginRegistered(string key, address pluginAddress);
    event ProfileUpdated(address indexed player, string name);

    constructor() {
    admin = msg.sender;
    }

    // 设置玩家资料
    function setProfile(string memory _name, string memory _avatar) public {
        profiles[msg.sender] = PlayerProfile({
            name: _name,
            avatar: _avatar
        });
        emit ProfileUpdated(msg.sender, _name);
    }

    // 管理员注册插件
    function registerPlugin(string memory _key, address _pluginAddress) public onlyAdmin {
        plugins[_key] = _pluginAddress;
        emit PluginRegistered(_key, _pluginAddress);
    }

    // 写调用插件
    function runPlugin(string memory _key, bytes memory _data) public returns (bytes memory) {
        address pluginAddress = plugins[_key];
        require(pluginAddress != address(0), "Plugin not found");
        (bool success, bytes memory result) = pluginAddress.call(_data);
        require(success, "Plugin call failed");
        return result;
    }

    // 读调用插件
    function runPluginView(string memory _key, bytes memory _data) public view returns (bytes memory) {
        address pluginAddress = plugins[_key];
        require(pluginAddress != address(0), "Plugin not found");
        (bool success, bytes memory result) = pluginAddress.staticcall(_data);
        require(success, "Plugin view call failed");
        return result;
    }

    // 查看玩家资料
    function getProfile(address _player) public view returns (string memory name, string memory avatar) {
        PlayerProfile memory profile = profiles[_player];
        return (profile.name, profile.avatar);
    }


}
