//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    
    struct PlayerProposal {
        string name;
        string avatar;
    }
    
    mapping(address => PlayerProposal) public profiles;
    mapping(string => address) public plugins;

    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProposal(_name, _avatar);
    }   

    function getProfile(address _player) external view returns (string memory, string memory) {
        PlayerProposal memory proposal = profiles[_player];
        return (proposal.name, proposal.avatar);
    }   

    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key]  = pluginAddress;

    }

    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    function runPlugin(string memory key, string memory functionSignature, address user, string memory argument) external {
        address pluginAddress = plugins[key];
        require(pluginAddress != address(0), "Plugin not found");
        bytes memory callData = abi.encodeWithSignature(functionSignature, user, argument);
        (bool success,) = pluginAddress.call(callData);
        require(success, "Plugin execution failed");
    }

    function runPluginView(string memory key, string memory functionSignature, address user) external view returns (string memory) {
        address pluginAddress = plugins[key];
        require(pluginAddress != address(0), "Plugin not found");
        bytes memory callData = abi.encodeWithSignature(functionSignature, user);
        // staticcall只读的
        (bool success, bytes memory result) = pluginAddress.staticcall(callData);
        require(success, "Plugin execution failed");
        return abi.decode(result, (string));
    }
}