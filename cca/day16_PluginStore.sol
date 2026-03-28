//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PluginStore{
    struct PlayerProfile{
        string name;
        string avatar;
    }
    mapping(address => PlayerProfile) public profiles;
    mapping(string => address)public plugins;

    function setProfile(string memory _name, string memory _avatar)external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user)external view returns(string memory,string memory){
        PlayerProfile memory profile = profiles[user];
        return (profile.name,profile.avatar);
    }

    function registerPlugin(string memory key, address pluginAdress)external {
        plugins[key] = pluginAdress;
    }//使用类似"achievements" 或 "weapons"这样的人类可读key来注册插件合约

    function runPlugin(
        string memory key,
        string memory functionSignature, 
        address user,
        string memory arguement)
        external{
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user, arguement);
        //括号里的部分looks like:setAchivement(user,achievement)
        (bool success, ) = plugin.call(data);//call 被调用的合约使用它的状态和存储
        require(success, "Plugin execution failed");
        }//低级调用：打包(abi.encode..)>>调用(call)>>检查成功(require)
    
    function runPluginView(
        string memory key,
        string memory functionSignature, 
        address user)
        view external returns(string memory){
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        //括号里的部分looks like:getAchivement(user)
        (bool success,bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view execution failed");
        
        return abi.decode(result,(string));//密码本(密码,(解码后语言格式)) 注意一定要确认success否则可能是报错信息
        }

}
//PluginStore.runPlugin("Weapon","setWeapon(address,string)", "msg.sender地址", "Golden Axe");

//getWeapon(address user)
//PluginStore.runPluginView("Weapon","getWeapon(address)","msg.sender地址");

//尽量复制才能减少出错！
