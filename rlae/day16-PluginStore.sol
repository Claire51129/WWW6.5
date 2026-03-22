// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract PluginStore {
    struct PlayerProfile{
        string name;
        string avatar;
    }
    mapping (address=>PlayerProfile) public profiles;
    mapping (string=>address) public plugins;
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender]=PlayerProfile(_name, _avatar);

    }
    function getProfile(address user) external view returns(string memory, string memory){ 
        PlayerProfile memory profile = profiles[user];
        return(profile.name,profile.avatar);
    }
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress; //插件key address 添加到系统中

    }
    function getPlugin(string memory key) external view returns(address) {
       return plugins[key];

    }
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
        ) external {
        address plugin = plugins[key]; //使用key= "achievements" 来获取插件地址
        require(plugin != address(0),"Invalid plugin address");
        bytes memory data =abi.encodeWithSignature(functionSignature,user,argument); //构建原始字节码
        //encodes a function call to store(bytes32,uint256) with the provided arguments
        (bool success,)=plugin.call(data);//低级 call 将请求发送到插件合约,插件在它自己的存储上下文中执行， 不是在 PluginStore 中
        require(success, "plugin execuation failed");//如果插件失败（由于无效参数或逻辑错误），整个交易将回滚

     }
     function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
     )external view returns(string memory){
        address plugin=plugins[key];
        require(plugin != address(0),"plugin not registered");
        bytes memory data =abi.encodeWithSignature(functionSignature,user); //仅使用用户地址准备函数调用所需的数据。
        (bool success,bytes memory result)=plugin.staticcall(data);
        require(success, "plugin view call failed");
        return abi.decode(result,(string)); //将返回的字节转换为字符串 可读
        
     }
   /*  pluginStore.runPlugin(
        "weapon",
        "setWeapon(address,string)",
        msg.sender,
        "Golden Axe"
     );
    pluginStore.runPluginView(
        "weapon",
        "getWeapon(address)",
        userAddress
     );
     */



}