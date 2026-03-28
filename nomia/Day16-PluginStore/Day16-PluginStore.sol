//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PluginStore{

    struct PlayerProfile{
        string name;
        string avatar;

    }

    mapping (address => PlayerProfile) public profiles;

    mapping(string => address)public plugins;

    //外部函数 任何账户都可以调用 设置自己的profile 传入名字和avatar
    function setProfile(string memory _name, string memory _avatar) external{
        profiles[msg.sender] = PlayerProfile(_name, _avatar);

    }
    //读取某个用户的资料
    function getProfile(address user)external view returns(string memory, string memory){
        PlayerProfile memory profile = profiles[user];
        return(profile.name, profile.avatar);

    }

    //登记plugin key：插件名字
    function registerPlugin(string memory key, address pluginAddress)external{
        plugins[key] = pluginAddress;

    }

    //根据key查询插件地址
    function getPlugin(string memory key) external view returns(address){
        return plugins[key];

    }

    //通过plugin store 调用某个插件里写的函数
    function runPlugin(
        string memory key, 
        string memory functionSignature, 
        address user,
        string memory argument
        ) external {
        //检查这个user是调用者本人
        require(user == msg.sender,"can only update your own data;");

        address plugin = plugins[key];
        //插件得注册
        require(plugin != address(0), "Plugin not registered");

    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    //.call()低级调用 返回（bool,bytes memory) 后面空着是因为不需要后面返回的数据了
    (bool success, ) = plugin.call(data);
    require(success, "Plugin execution failed");

}
    //只读
    function runPluginView(string memory key, string memory functionSignature, address user)external view returns(string memory){
        //根据key查插件地址 
        address plugin = plugins[key];
        require(plugin != address(0), "No plugin found");
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        //staticcall 只读调用 只能读取 result是返回的原始数据
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin execution failed");
        //如果成功了就把return的bytes解码回string然后return
        return abi.decode(result,(string));
    }

}

//pluginStore.runPlugin("weapon", "setWeapon(address, string)", msg.sender, "URFIRED");