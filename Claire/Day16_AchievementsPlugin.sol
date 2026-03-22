//SPDX-License-Identifier: MIT
// 代码开源协议，MIT是最宽松的协议，任何人都可以自由使用

pragma solidity ^0.8.0;
// 指定Solidity编译器版本为0.8.0及以上

contract AchievementsPlugin{
// 定义一个合约，叫"成就插件"
// 作用：记录玩家获得的最新成就
// 可以注册到PluginStore中，作为插件使用

    mapping(address => string) public latestAchievement;
    // mapping：映射，像一个字典，通过键找到对应的值
    // address => string：通过玩家地址，找到他最新获得的成就
    // public：自动生成getter函数，外部可以直接调用latestAchievement(地址)来查看
    // 作用：存储每个玩家的最新成就

    function setAchievement(address user, string memory achievement) public{
    // 函数：设置玩家的最新成就
    // address user：要设置成就的玩家地址
    // string memory achievement：成就名称（存在内存中，临时存储）
    // public：公开函数，任何人都可以调用
        
        latestAchievement[user] = achievement;
        // 把成就名称存到mapping里
        // 键是玩家地址，值是成就名称
        // 如果这个玩家之前有成就，会被覆盖（只保留最新的）
    }

    function getAcheievement(address user)public view returns(string memory){
    // 函数：查看玩家的最新成就
    // address user：要查询的玩家地址
    // public view：公开的只读函数，不修改链上数据，调用免费
    // returns(string memory)：返回成就名称（字符串类型）
        
        return latestAchievement[user];
        // 从mapping中取出这个玩家的成就并返回
        // 如果玩家还没有设置过成就，返回空字符串""
    }

}

// 下面这行是合约地址注释，不是代码
// 0x5C7078010eA1046720D08Daef080e1F75bB13682
// 这应该是这个合约部署后的地址（可能是测试网或主网地址）
// 部署后可以通过这个地址来调用合约功能