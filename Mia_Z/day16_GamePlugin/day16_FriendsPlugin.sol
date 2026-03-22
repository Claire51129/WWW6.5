// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * FriendsPlugin
 * - 作为 Game 的“好友系统”插件存在
 * - 由 PluginStore 通过 runPlugin 调用
 *
 * 为了让签名保持简单，朋友标识使用 string（可以是地址、昵称等），
 * 这样函数签名都保持为 (address,string) 方便通过 abi.encodeWithSignature 调用。
 */
contract FriendsPlugin {
    // user => friendId(string) => isFriend
    mapping(address => mapping(string => bool)) public isFriend;

    /**
     * 添加好友
     * 预期由 PluginStore 调用：addFriend(user, friendId)
     */
    function addFriend(address user, string memory friendId) public {
        isFriend[user][friendId] = true;
    }

    /**
     * 移除好友
     * 预期由 PluginStore 调用：removeFriend(user, friendId)
     */
    function removeFriend(address user, string memory friendId) public {
        isFriend[user][friendId] = false;
    }

    /**
     * 查询是否为好友
     * 返回 string 方便 PluginStore.runPluginView 统一处理
     */
    function checkFriend(
        address user,
        string memory friendId
    ) public view returns (string memory) {
        if (isFriend[user][friendId]) {
            return "isFriend";
        } else {
            return "notFriend";
        }
    }
}

