// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 *把“玩家档案 + 插件调度”放在一个**核心合约（PluginStore）**里；
    各种可扩展玩法（成就、排行榜、道具系统……）做成独立插件合约；
    用 abi.encodeWithSignature + call/staticcall 做一个通用的跨合约调用入口。
 * 
 * 
 */
contract AchievementsPlugin {
    // user => achievement string
    mapping(address => string) public latestAchievement;

    // Set achievement for a user (called by PluginStore)
    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    // Get achievement for a user
    function getAchievement(address user) public view returns (string memory) {
        return latestAchievement[user];
    }
}


/**
     * day14 模块化（假设是那种拆文件/库的风格）：

    典型写法：contract Game is ProfileModule, AchievementModule, ...
    编译后是一个合约 bytecode，一起部署；
    你要新增一个模块，通常要重新部署整个合约（或用代理升级）。
    day16 插件化：

    每个插件单独部署，如 AchievementsPlugin；
    PluginStore 通过字符串 + 地址来找到插件；
    想新增插件？只要：registerPlugin("newPlugin", newAddress)；
    想替换插件？直接把 plugins["achievements"] 改成新地址（当然真实生产环境要加 onlyOwner 等权限）。
 */