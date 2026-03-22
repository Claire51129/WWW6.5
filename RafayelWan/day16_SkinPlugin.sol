// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 皮肤插件：给玩家设置/查看皮肤
contract SkinPlugin {
    // 记录每个玩家的皮肤
    mapping(address => string) public playerSkin;

    // 设置皮肤
    function setSkin(address user, string memory skin) public {
        playerSkin[user] = skin;
    }

    // 查看皮肤
    function getSkin(address user) public view returns (string memory) {
        return playerSkin[user];
    }
}