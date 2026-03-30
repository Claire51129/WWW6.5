//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract PluginStore{

    struct PlayerProfile{
        string name;
        string avator;
    }

    mapping(address => PlayerProfile) public profiles;

    mapping(string  => address) public plugins;

    //Core function
    function setProfile(string memory _name, string memory _avator) external {
        profiles[msg.sender] = PlayerProfile(_name,_avator);
    }

    function getProfile(address _player) external view returns(string memory, string memory){
        PlayerProfile memory profile = profiles[_player];
        return(profile.name, profile.avator);
    }
    //plug Management

    function registerPlug(string memory _key, address _PluginAddress) external{
        plugins[_key] = _PluginAddress;
    }

    function getPlugin(string memory _key)external view returns(address){
        return plugins[_key];
    }

    //Plugin execution
    function runPlugin(
        string memory _key,
        string memory _functionSignature,
        address _user,
        string memory argument
    )external{
        address plugin = plugins[_key];
        require(plugin != address(0),"Plugin not registered");
        bytes memory data = abi.encodeWithSignature(_functionSignature,_user ,argument);
        (bool success, ) = plugin.call(data) ;
        require(success ,"plugin execution failed");
    }

    function runPluginView(
        string memory _key,
        string memory _functionSignature,
        address _user
    )external view returns(string memory){
        address plugin = plugins[_key];
        require(plugin != address(0),"Plugin not registered"); 
        bytes memory data = abi.encodeWithSignature(_functionSignature,_user);
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success ,"plugin view failed");
        return abi.decode(result,(string));
    }
}
