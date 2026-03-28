// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SubscriptionStorageLayout} from "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {    //必须和Proxy用同一个存储结构
    // 添加套餐：设置套餐
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    // 订阅函数：检查套餐，必须存在
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");    //检查钱，钱要够
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];    //读取用户数据：找到你的会员卡
        if (block.timestamp < s.expiry) {   //判断是否续费，如果还没过期，在原基础上延长，否则重新开始
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;    //更新数据：设置套餐+恢复状态
        s.paused = false;
    }

    //查询是否有效：判断：没过期+没暂停
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
}


// LogicV1: 0xE5f2A565Ee0Aa9836B4c80a07C8b32aAd7978e22