// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {

    address public owner;

    struct PlayerProfile {
        string name;
        string avatar;
    }

    struct PluginInfo {
        address pluginAddress;
        uint16 version;
        bool active;
    }

    mapping(address => PlayerProfile) public profiles;
    mapping(string => PluginInfo) public plugins; // key → PluginInfo

    event PluginRegistered(string key, address pluginAddress, uint16 version);
    event PluginDeactivated(string key);
    event ProfileUpdated(address indexed user, string name);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can manage plugins");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
        emit ProfileUpdated(msg.sender, _name);
    }

    function getProfile(address _user) external view returns (string memory, string memory) {
        PlayerProfile memory p = profiles[_user];
        return (p.name, p.avatar);
    }

    function registerPlugin(string memory _key, address _pluginAddress, uint16 _version) external onlyOwner {
        require(_pluginAddress != address(0), "Invalid plugin address");
        plugins[_key] = PluginInfo({
            pluginAddress: _pluginAddress,
            version: _version,
            active: true
        });
        emit PluginRegistered(_key, _pluginAddress, _version);
    }

    function deactivatePlugin(string memory _key) external onlyOwner {
        plugins[_key].active = false;
        emit PluginDeactivated(_key);
    }

    function getPlugin(string memory _key) external view returns (address, uint16, bool) {
        PluginInfo memory info = plugins[_key];
        return (info.pluginAddress, info.version, info.active);
    }

    // ─── 插件调用：call（在插件合约的 context 执行）─────────────

    function runPlugin(
        string memory _key,
        string memory _functionSignature,
        address _user,
        string memory _argument
    ) external {
        PluginInfo memory info = plugins[_key];
        require(info.pluginAddress != address(0), "Plugin not registered");
        require(info.active, "Plugin is deactivated");

        bytes memory data = abi.encodeWithSignature(_functionSignature, _user, _argument);
        (bool success, ) = info.pluginAddress.call(data);
        require(success, "Plugin call failed");
    }

    function runPluginView(
        string memory _key,
        string memory _functionSignature,
        address _user
    ) external view returns (string memory) {
        PluginInfo memory info = plugins[_key];
        require(info.pluginAddress != address(0), "Plugin not registered");
        require(info.active, "Plugin is deactivated");

        bytes memory data = abi.encodeWithSignature(_functionSignature, _user);
        (bool success, bytes memory result) = info.pluginAddress.staticcall(data);
        require(success, "Plugin staticcall failed");

        return abi.decode(result, (string));
    }
}
