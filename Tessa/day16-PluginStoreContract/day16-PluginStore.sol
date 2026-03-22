// 主合约负责调度，插件负责存数据和逻辑
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

    contract PluginStore{    //创建游戏大厅

        // 玩家信息结构
        struct PlayerProfile{  //玩家信息卡
            string name;    //名字
            string avatar;    //头像
        }

        mapping(address => PlayerProfile) public profiles;    //钱包地址 → 玩家信息
        mapping(string => address)public plugins;    //插件名字 → 插件地址（类似通讯录 名字→电话，插件名字是调用时自己填）

        // 设置玩家信息
        function setProfile(string memory _name, string memory _avatar) external{    //玩家设置自己的资料
            profiles[msg.sender] = PlayerProfile(_name, _avatar);    //把你的信息存起来
        }

        // 获取玩家信息
        function getProfile(address user)external view returns(string memory, string memory){    //查询某个玩家
            PlayerProfile memory profile = profiles[user];    //取出这个人的资料
            return(profile.name, profile.avatar);    //返回名字+头像

        }
    
        // 注册插件
        function registerPlugin(string memory key, address pluginAddress)external{    // 如：weapon → 武器地址
            plugins[key] = pluginAddress;    //存起来
        }

        // 获取插件
        function getPlugin(string memory key) external view returns(address){   //查插件地址
            return plugins[key];
        }

        //【重点】调用插件（写数据）
        function runPlugin(string memory key, string memory functionSignature, address user, string memory argument) external {
        address plugin = plugins[key];    //找到插件地址
        require(plugin != address(0), "Plugin not registered");    //必须存在插件

        //【超重点】把函数“打包”
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);   // 写一封指令信
        (bool success, ) = plugin.call(data);    //找插件干活
        require(success, "Plugin execution failed");    //确保成功
    }

        // 只读：只查询，不修改
        function runPluginView(string memory key, string memory functionSignature, address user) external view returns(string memory){
            address plugin = plugins[key];
            require(plugin != address(0), "No plugin found");
            bytes memory data = abi.encodeWithSignature(functionSignature, user);   //打包查询请求
            (bool success, bytes memory result) = plugin.staticcall(data);    //staticcall：只能读，不能改
            require(success, "Plugin execution failed");
            return abi.decode(result,(string));    //把结果解码
        }
    }

// pluginStore.runPlugin("weapon","setWwapon(address,string)",msg.sender, "Golden Axe"); 打包函数，变成一段数据
// PluginStore(主合约)：游戏大厅——负责管理玩家+插件；WeaponPlugin:武器店；AchievementPlugin:成就系统
// call=让别人帮你干活，数据记在别人哪里，用的是对方的存储；——用别人的仓库干活
// staticcall=只能读不能改，用于查询合约
// delegatecall：借别人的代码，但改自己的数据，用于升级合约