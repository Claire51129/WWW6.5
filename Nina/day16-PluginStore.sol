// 模块化的玩家配置文件系统 - delegatecall

/** 谈谈调用：call、delegatecall 和 staticcall
 *  以A合约调用B合约为例：
    call：msg.sender=A合约地址，A合约调用B合约的函数，修改B合约的状态和存储
    delegatecall：msg.sender=最初调用A合约的user address，A合约调用B合约的函数，修改A合约的状态和存储
    staticcall：msg.sender=A合约地址，A合约调用B合约的函数，只读B合约的状态和存储
*/

/** 游戏计划：构建我们的模块化玩家系统
    我们没有将所有功能都塞进核心合约中，
    核心合约——存储每位玩家的个人资料；
    附加功能模块/插件——每个插件都是一个独立的合约，负责特定功能。而且由于插件是模块化的，我们可以在任何时候升级、替换或添加新的插件——无需重新部署整个系统。
*/

/** 构建插件库
    - **`AchievementsPlugin`**– 存储玩家最近获得的成就
    - **`WeaponStorePlugin`** – 存储玩家装备的武器
    这些插件不是独立运行的——**PluginStore** 会动态调用它们：
    - 对于状态改变的操作（如设置武器），我们使用 **`call`**
    - 对于只读查询（如检查玩家的成就），我们使用 **`staticcall`**
    - 如果我们想要共享存储（比如在可升级系统中），甚至可以替换为 **`delegatecall`** — 但目前，`call` 和 `staticcall` 使事情保持简单和安全。
*/

/** PluginStore合同
    本合同定义了玩家资料中心 ——每位玩家都有一个基本资料（姓名和头像），他们可以通过插件连接附加功能。
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
    struct PlayerProfile {
        string name;
        string avatar;
    }

    mapping(address => PlayerProfile) public profiles;

    // === Multi-plugin support ===
    mapping(string => address) public plugins;

    // ========== Core Profile Logic ==========

    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }
    /** [PlayerProfile memory profile = profiles[user];]

        这里声明的变量profile是一个结构体类型的变量。
        在 Solidity 中，数组（Array）、结构体（Struct） 和 映射（Mapping） 被称为“引用类型”。当你声明一个这些类型的变量时，必须告诉编译器数据放在哪。
        你实际上是命令 EVM：“从硬盘里把这个结构体完整地复制一份，放到内存（RAM）里。”
        如果去掉 memory ，编译器会报错。因为它不知道你是想建立一个指向硬盘的“指针”（storage），还是想拷贝一份到临时空间（memory）。

        注意到这里mutability（可变性）是view。如果你想省点 Gas，且不需要修改数据，其实可以把memory改成storage：使用 storage 只是创建了一个“指针”，没有发生数据拷贝
        - memory profile：把名字和头像从硬盘拷贝到内存（费点 Gas，但安全，随便改）。
        - storage profile：只是指了一下硬盘里的位置（省 Gas，因为没搬运数据）。
    */

    // ========== Plugin Management ==========

    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ========== Plugin Execution ==========

    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered"); // 1. 安全检查：插件地址是否已在合约中注册过，注册过才能运行

        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument); // 2. 封包：（1）翻译成二进制，得到的 data 是一串十六进制代码【计算 bytes4 selector = bytes4(keccak256(bytes(functionSignature))) & 调用 abi.encode(user, argument) 把剩下的东西打包】。（2）data包含信息：目标函数的“指纹”（Selector）——有它就知道调用目标合约的哪个函数了；user 和 argument 是目标函数需要的参数——注意这里限制了插件函数必须接收一个地址和一个字符串作为参数。

        (bool success, ) = plugin.call(data); //3. 发送：通过 .call() 实现 PluginStore 调用插件合约（plugin 变量指向的那个地址），把 data 传到插件合约上，在目标合约中执行目标函数，修改目标合约中存储的变量。
        require(success, "Plugin execution failed"); // 4. 确认 (Safety Check)：底层调用（call）不会自动回滚。即使插件合约执行时因为余额不足或代码错误崩了，call 也只是返回 false， runPlugin 依然会继续往下走。必须手动用 require 检查 success。如果失败，这一行会强制让整笔交易失败并回滚状态。
    }

    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user); // 注意相对于上面写入的函数，这里是用不同的签名调用不同的函数来查看
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view call failed");

        return abi.decode(result, (string)); // 返回的值相当于runPlugin函数中的argument变量
    }

}
