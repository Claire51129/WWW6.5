// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price; //将套餐的价格存储在 planPrices[planId] 中
        planDuration[planId] = duration; //设置套餐的持续时间
    }
    function subscribe(uint8 planId) external payable {
    require(planPrices[planId] > 0, "Invalid plan");//套餐是否有效
    require(msg.value >= planPrices[planId], "Insufficient payment");//用户是否发送了足够的 ETH

    Subscription storage s = subscriptions[msg.sender]; //从 subscriptions 映射中获取调用者的订阅记录
    if (block.timestamp < s.expiry) {
        s.expiry += planDuration[planId]; //延长订阅
    } else {
        s.expiry = block.timestamp + planDuration[planId]; //全新的订阅
    }

    s.planId = planId;
    s.paused = false; //取消暂停订阅 会自动“恢复”已暂停的订阅（对于 V2 等功能很有用）
    }
    function isActive(address user) external view returns (bool) {
    Subscription memory s = subscriptions[user];
    return (block.timestamp < s.expiry && !s.paused);//当前时间在订阅到期之前&订阅未暂停
    }
    

}