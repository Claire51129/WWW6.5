// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    // 玩家配置文件
    struct PlayerProfile {//用于组织玩家相关信息
        string name;//用来存储玩家名字
        string avatar;//用来存储头像相关信息。
    }
    
    // 状态变量
    mapping(address => PlayerProfile) public profiles;//创建了一个公开的映射，将以太坊地址映射到PlayerProfile结构体，用于存储与地址关联的玩家资料。
    mapping(string => address) public plugins;//创建了一个公开映射，将字符串映射到以太坊地址，可用于存储与字符串相关联的地址信
    
    // 设置配置文件
    function setProfile(string memory _name, string memory _avatar) external {//声明外部函数setProfile，接收两个字符串参数
        profiles[msg.sender] = PlayerProfile({//根据发送者地址，在profiles映射中设置PlayerProfile
            name: _name,//将传入的名字赋值给PlayerProfile的name
            avatar: _avatar//将传入的头像赋值给PlayerProfile的avatar
        });
    }
    
    // 获取配置文件
    function getProfile(address user) external view returns (string memory, string memory) {//声明外部只读函数getProfile，接收地址参数，返回两个字符串
        PlayerProfile memory profile = profiles[user];//根据传入地址从profiles映射获取PlayerProfile
        return (profile.name, profile.avatar);//返回获取到的PlayerProfile中的名字和头像信息
    }
    
    // 注册插件
    function registerPlugin(string memory key, address pluginAddress) external {//声明外部函数registerPlugin，接收字符串和地址参数
        plugins[key] = pluginAddress;//将传入的地址存储到plugins映射中，键为传入的字符串。
    }
    
    // 获取插件地址
    function getPlugin(string memory key) external view returns (address) {//声明外部只读函数getPlugin，接收字符串参数并返回地址
        return plugins[key];//根据传入的字符串键从plugins映射中返回对应的地址。
    }
    
    // 运行插件(修改状态) - 使用call
    function runPlugin(//声明外部函数
        string memory key,//声明
        string memory functionSignature,//声明
        address user,//类型为地址
        string memory argument//声明
    ) external {
        address plugin = plugins[key];//从plugins映射获取与键对应的插件地址。
        require(plugin != address(0), "Plugin not found");//检查获取到的插件地址是否为零地址，不为零则继续执行，否则抛出异常
        
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature(
            functionSignature, 
            user, 
            argument//将其存储在data变量中，用于后续的合约调用
        );
        
        // 调用插件
        (bool success, ) = plugin.call(data);//使用call函数调用plugin地址合约，传入编码后数据data，返回调用是否成功
        require(success, "Plugin call failed");//检查调用结果success，若为假则抛出 “Plugin call failed” 异常
    }
    
    // 查询插件(只读) - 使用staticcall
    function runPluginView( //声明外部只读函数runPluginView。
        string memory key,//定义函数参数
        string memory functionSignature,
        address user
    ) external view returns (string memory) { //从plugins映射获取与key对应的插件地址
        address plugin = plugins[key];//检查插件地址是否为零地址，非零则继续，否则抛出 “Plugin not found”。
        require(plugin != address(0), "Plugin not found");
        
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        //进行编码，并将结果存储在data变量中，用于后续的合约调用。


        // 只读调用
        (bool success, bytes memory result) = plugin.staticcall(data);//使用staticcall对plugin合约进行只读调用，传入编码数据data，并返回调用是否成功及结果
        require(success, "Plugin call failed"); //检查调用结果success，若为假则抛出 “Plugin call failed” 异常
        
        // 解码返回数据
        return abi.decode(result, (string)); //使用abi.decode函数对result进行解码，按照(string)的格式解析数据，并将解码后的数据返回，用于获取插件调用的结果
    }
}
