// SPDX-License-Identifier: MIT
// 代码开源许可证，MIT是最宽松的协议，任何人都可以用

pragma solidity ^0.8.0;
// 指定Solidity编译器版本，^0.8.0表示0.8.0及以上版本（但不包括0.9.0）

contract PluginStore{
// 定义一个合约，叫PluginStore（插件商店）
// 作用：像应用商店一样管理插件，可以通过插件名调用插件功能

    struct PlayerProfile{
    // 定义一个结构体，叫PlayerProfile（玩家档案）
    // 结构体 = 自定义的数据类型，可以把多个数据打包在一起
        string name;
        // 字符串类型，存玩家的名字
        
        string avatar;
        // 字符串类型，存玩家的头像（可以是图片URL或IPFS哈希）
    }
    // 结构体定义结束

    mapping(address =>PlayerProfile) public profiles;
    // mapping = 映射，像字典一样，通过一个键找到对应的值
    // address => PlayerProfile：通过地址找到对应的玩家档案
    // public = 自动生成一个getter函数，外部可以直接调用profiles(地址)来查看
    // 作用：每个地址可以存储一份自己的档案

    mapping(string => address)public plugins;
    // 映射：通过插件名（字符串）找到插件合约的地址
    // 作用：就像手机桌面，通过APP名字找到APP的位置
    // public：外部可以直接调用plugins("插件名")来获取插件地址

    function setProfile(string memory _name, string memory _avatar) external{
    // 函数：设置自己的档案
    // string memory：字符串存在内存中（临时存储，便宜）
    // external：只能从外部调用，不能从合约内部调用（省钱）
        
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
        // profiles[msg.sender]：把当前调用者的地址作为键
        // PlayerProfile(_name, _avatar)：创建一个新的PlayerProfile结构体
        // 把名字和头像存进去
        // 整体意思：调用者给自己存了一份档案
    }

    function getProfile(address user)external view returns(string memory, string memory){
    // 函数：查看某个人的档案
    // address user：要查谁的档案，传入他的地址
    // view：只读函数，不修改链上数据，调用免费
    // returns(string memory, string memory)：返回两个字符串（名字和头像）
        
        PlayerProfile memory profile = profiles[user];
        // 从mapping中取出这个人的档案，存到内存中
        // memory：临时存储，用完就丢
        
        return(profile.name, profile.avatar);
        // 返回档案里的名字和头像
    }

    function registerPlugin(string memory key, address pluginAddress)external{
    // 函数：注册插件
    // string memory key：插件的名字，比如"weapon"
    // address pluginAddress：插件合约的地址
        
        plugins[key] = pluginAddress;
        // 把插件名和插件地址的对应关系存到mapping里
        // 之后就可以通过插件名找到插件地址
    }

    function getPlugin(string memory key) external view returns(address){
    // 函数：通过插件名获取插件地址
    // view：只读查询
        
        return plugins[key];
        // 从mapping中取出插件地址并返回
    }

    function runPlugin(string memory key, string memory functionSignature, address user,string memory argument) external {
    // 函数：运行插件（可以修改链上数据）
    // key：插件名字
    // functionSignature：要调用的函数签名，比如"setWeapon(address,string)"
    // user：用户地址
    // argument：传给插件的参数，比如"Golden Axe"
        
    address plugin = plugins[key];
    // 通过插件名，从mapping中取出插件合约的地址
    
    require(plugin != address(0), "Plugin not registered");
    // require = 条件检查，如果不满足就回滚交易并报错
    // address(0) = 零地址（0x0000000000000000000000000000000000000000）
    // 检查插件地址不是零地址，确保插件已经注册过

    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    // abi.encodeWithSignature = 把函数签名和参数打包成二进制数据
    // 为什么要打包？因为底层call调用需要二进制格式的数据
    // 函数签名 = 函数名+(参数类型)，比如"setWeapon(address,string)"
    // 打包后得到的数据格式：函数选择器(4字节) + 参数1 + 参数2...
    // 这个过程叫ABI编码
    
    (bool success, ) = plugin.call(data);
    // .call() = 低级调用，可以调用任何合约的任何函数
    // 参数data是打包好的二进制数据
    // 返回两个值：
    //   - success：bool类型，调用是否成功
    //   - 第二个返回值被忽略了（用逗号空着），实际是函数的返回值
    // .call()可以修改链上数据，所以消耗gas
    
    require(success, "Plugin execution failed");
    // 如果调用失败（success是false），交易回滚并报错
}

    function runPluginView(string memory key, string memory functionSignature, address user)external view returns(string memory){
    // 函数：运行插件（只读查询，不修改数据）
    // view：这个函数本身也是只读的
    // returns(string memory)：返回一个字符串（插件的查询结果）
        
        address plugin = plugins[key];
        // 通过插件名获取插件地址
        
        require(plugin != address(0), "No plugin found");
        // 检查插件存在
        
        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        // 打包函数签名和参数（只有user一个参数）
        
        (bool success, bytes memory result) = plugin.staticcall(data);
        // .staticcall() = 静态调用，和call类似但是不能修改链上数据
        // 如果调用的函数试图修改数据，会失败
        // 返回两个值：
        //   - success：是否成功
        //   - result：函数返回的数据（二进制格式）
        
        require(success, "Plugin execution failed");
        // 确保调用成功
        
        return abi.decode(result,(string));
        // abi.decode = 把二进制数据解码成原始类型
        // result是二进制数据，解码成string类型后返回
    }
}

//pluginStore.runPlugin("weapon", "setWeapon(address, string)", msg.sender, "Golden Axe");
// 这是调用示例，不是代码的一部分
// 解释：调用PluginStore的runPlugin函数
//   参数1："weapon" → 插件名
//   参数2："setWeapon(address, string)" → 要调用的函数签名
//   参数3：msg.sender → 当前用户地址
//   参数4："Golden Axe" → 传给插件的参数
// 最终效果：在weapon插件上调用setWeapon函数，给当前用户装备"Golden Axe"