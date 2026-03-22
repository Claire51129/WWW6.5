// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    //订阅新套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        //续费场景
        Subscription storage s = subscriptions[msg.sender];//storage时将用户的订阅数据永久储存在区块链上，下次用户调用合约时可以直接读取
        //如果续费时，用户之前购买的套餐还没结束
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];//那就把原本套餐结束时间+新订阅的时间
        } else {
            s.expiry = block.timestamp + planDuration[planId];//如果不是，就从现在开始计算
        }

        s.planId = planId;//将现在订阅的id更新成用户刚购买的id
        s.paused = false;//确定用户订阅处于激活状态
    }

    //用户查询订阅服务是否过期
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];//从区块链中取出用户的个人信息放在临时储存中
        return (block.timestamp < s.expiry && !s.paused);//如果用户的订阅结束时间大于当且时间  同时订阅暂停是false状态
    }
}