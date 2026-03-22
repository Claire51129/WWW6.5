// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore{

    struct PlayerProfile{
        string name;
        string avatar;

    }
    mapping(address => PlayerProfile) public profiles;
    //查询这个地址的状态，eg地址有多少钱，什么等级
    mapping(string => address) public plugins;
    //类似在Google输入string，它给你返回IP地址
    //eg这个ID归谁管，这个功能在哪个合约？

    function setProfile(string memory _name, string memory _avatar) external{
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user) external view returns(string memory, string memory)
    {// 在函数末尾，必须显式写出retrun（a, b)
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    function registerPlugin(string memory key, address pluginAddress) external{
        plugins[key] = pluginAddress;
    }

    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }
    function runPlugin(
        string memory key,
        string memory functionSignature,
        //setWeapon(address,string)对应只是一个标签贴纸
        //把函数名定义为string的唯一目的就是自由，想调用什么函数就在调用runPlugin的时候临时传那个函数的名字，只要函数名对应的函数在目标合约真实存在就能跑通
        address user,
        string memory argument
    )external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        //把函数名（4位数的数字代号-函数选择器）和参数混合打包成一段十六进制的bytes数据
        //把标签贴纸翻译成发送给另一个合约的指令
        
        (bool success,) = plugin.call(data);
        //地址为Plugin的合约，拿着data执行
        //.call 会返回两个值：(bool success, bytes memory returnData)
        require(success, "Plugin execution failed");
    
    }

    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    )external view returns(string memory){
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);
        //staticcall不能改变状态，是只读的
        require(success, "Plugin view call failed");

        return abi.decode(result, (string));
        //按照字符串的规则去拆解这段乱码，并把它还原回文字
    }


}