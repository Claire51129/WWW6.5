// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==========================================
// 插件 1：成就中心 (独立合约)
// ==========================================
contract AchievementsPlugin {
    mapping(address => string) public latestAchievement;

    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}

// ==========================================
// 插件 2：武器商店 (独立合约)
// ==========================================
contract WeaponStorePlugin {
    mapping(address => string) public equippedWeapon;

    function setWeapon(address user, string memory weapon) public {
        equippedWeapon[user] = weapon;
    }

    function getWeapon(address user) public view returns (string memory) {
        return equippedWeapon[user];
    }
}

// ==========================================
// 核心主板：大管家 (PluginStore)
// ==========================================
contract PluginStore {
    // 1. 玩家核心数据（极度精简，只存名字和头像）
    struct PlayerProfile {
        string name;
        string avatar;
    }
    mapping(address => PlayerProfile) public profiles;

    // 2. 插件注册表（记录“插件代号”对应的“合约地址”）
    mapping(string => address) public plugins;

    // 3. 基础功能：设置和查询玩家基础档案
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // 4. 插件管理：把新的插件卡带插到主板上
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // 5. 万能 USB 接口（写入数据版）
    function runPlugin(string memory key, string memory functionSignature, address user, string memory argument) external {
        // 找到目标插件的地址
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        // 核心魔法：把文字指令打包成机器能懂的字节码（飞镖）
        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);

        // 用 call 强行把飞镖扔给插件合约
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }

    // 6. 万能 USB 接口（只读查询版）
    function runPluginView(string memory key, string memory functionSignature, address user) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        // 打包查询指令
        bytes memory data = abi.encodeWithSignature(functionSignature, user);

        // 用 staticcall 进行纯查询，不改变任何数据，省钱！
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view call failed");

        // 核心魔法：把查回来的机器码，翻译回人类看得懂的字符串
        return abi.decode(result, (string));
    }
}
