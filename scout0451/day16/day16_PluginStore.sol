//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PluginStore{

    //结构体储存玩家资料
    struct PlayerProfile{
        string name;
        string avatar;
    }

    mapping(address =>PlayerProfile) public profiles;
    
    //使用这个映射来通过字符串键注册插件，并将它们映射到部署的合约地址
    mapping(string => address)public plugins;

    function setProfile(string memory _name, string memory _avatar) external{
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user)external view returns(string memory, string memory){
        PlayerProfile memory profile = profiles[user];
        return(profile.name, profile.avatar);

    }

    //插件管理：识别插件的名称——可以将其视为 URL 别名或插件名称；你要注册的插件的智能合约地址
    function registerPlugin(string memory key, address pluginAddress)external{
        plugins[key] = pluginAddress;
    }

    //返回插件地址，适用于 UI 工具或验证插件是否已注册
    function getPlugin(string memory key) external view returns(address){
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
        //按函数签名编码调用数据
        //functionSignature 看起来像： "setAchievement(address,string)"
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        (bool success, ) = plugin.call(data);//插件在它自己的存储上下文中执行
        require(success, "Plugin execution failed");
    }

    function runPluginView(string memory key, string memory functionSignature, address user)external view returns(string memory){
        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);//staticcall不能改变状态、只读。
        require(success, "Plugin execution failed");
        return abi.decode(result,(string));//将返回的字节转换为字符串
    }
}

//pluginStore.runPlugin("weapon", "setWeapon(address, string)", msg.sender, "Golden Axe");