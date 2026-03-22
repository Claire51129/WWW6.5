// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 主合约：管理玩家 + 调用插件
contract PluginStore {
    // 玩家信息
    struct Player {
        string name;
    }
    mapping(address => Player) public players;

    // 插件仓库（名字 => 插件地址）
    mapping(string => address) public plugins;

    // 1. 设置自己的名字
    function setName(string memory _name) external {
        players[msg.sender] = Player(_name);
    }

    // 2. 注册插件（把皮肤插件加进来）
    function registerPlugin(string memory name, address plugin) external {
        plugins[name] = plugin;
    }

    // 3. 调用插件【改数据】（设置皮肤）
    function runPlugin(string memory pluginName, address user, string memory skin) external {
        address plugin = plugins[pluginName];
        require(plugin != address(0), "Plugin not exists"); // 这里用英文引号和英文提示

        // 打包指令：调用setSkin
        bytes memory data = abi.encodeWithSignature("setSkin(address,string)", user, skin);
        (bool ok,) = plugin.call(data);
        require(ok, "Execute failed");
    }

    // 4. 调用插件【查数据】（查看皮肤）
    function viewPlugin(string memory pluginName, address user) external view returns (string memory) {
        address plugin = plugins[pluginName];
        require(plugin != address(0), "Plugin not exists"); // 这里也用英文引号

        bytes memory data = abi.encodeWithSignature("getSkin(address)", user);
        (bool ok, bytes memory res) = plugin.staticcall(data);
        require(ok, "Query failed");
        
        return abi.decode(res, (string));
    }
}