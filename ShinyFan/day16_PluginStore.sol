//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore{

    //创建结构体
    struct PlayerProfile{//玩家个人资料
        string name;
        string avatar;//头像？
    }

    mapping(address =>PlayerProfile) public profiles;
    mapping(string => address)public plugins;

    //建立个人资料
    function setProfile(string memory _name, string memory _avatar) external{
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user)external view returns(string memory, string memory){//returns的参数只能是什么类型的变量，不写变量名
        PlayerProfile memory profile = profiles[user];
        return(profile.name, profile.avatar);

    }

    function registerPlugin(string memory key, address pluginAddress)external{
        plugins[key] = pluginAddress;
    }

    function getPlugin(string memory key) external view returns(address){
        return plugins[key];
    }
    //key是插件的名称，，functionsignature是函数的名称

    function runPlugin(
        string memory key, 
        string memory functionSignature, 
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        //将bytes memory data理解为小纸条，所有等号右侧的信息会记录在这张纸条上
        //abi是翻译器，将人的语言翻译成机器的语言；encode是打包，abi.encode就是翻译并且打包信息
        //signature是函数签名的意思，withsignature就是带着函数名字一起打包，括号里也是要打包的信息
        (bool success, ) = plugin.call(data);
        //call是让其他合约来干活，这里的其他合约就是plugin，deta里有执行函数以及参数
        //一定会返回两个东西，一个是T/F，一个是数据，这里因为不需要数据所以直接写了bool success。虽然不需要返回数据但逗号也不能忘
        require(success, "Plugin execution failed");
    }


    function runPluginView(//问别的合约要数据，只读
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);//staticcall是只读的call
        require(success, "Plugin view call failed");

        return abi.decode(result, (string));
    }
}