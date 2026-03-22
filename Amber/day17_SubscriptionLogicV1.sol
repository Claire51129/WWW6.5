// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/*
    第一版逻辑合约

    负责：
    - 创建套餐
    - 用户订阅
    - 查询订阅状态

    注意：
    逻辑合约本身不保存数据
    数据全部存储在 Proxy 中
*/

contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    /*
        添加订阅套餐
        planId  : 套餐编号
        price   : 价格
        duration: 持续时间（秒）
    */
    function addPlan(
        uint8 planId,
        uint256 price,
        uint256 duration
    ) external {

        // 设置套餐价格
        planPrices[planId] = price;

        // 设置套餐持续时间
        planDuration[planId] = duration;
    }

    /*
        用户订阅
        需要发送 ETH
    */
    function subscribe(uint8 planId) external payable {

        // 确认套餐存在
        require(planPrices[planId] > 0, "Invalid plan");

        // 确认支付足够
        require(msg.value >= planPrices[planId], "Insufficient payment");

        // 获取用户订阅信息
        Subscription storage s = subscriptions[msg.sender];

        // 如果订阅还没过期
        if (block.timestamp < s.expiry) {

            // 延长订阅
            s.expiry += planDuration[planId];

        } else {

            // 新订阅
            s.expiry = block.timestamp + planDuration[planId];
        }

        // 更新套餐
        s.planId = planId;

        // 确保订阅不是暂停状态
        s.paused = false;
    }

    /*
        查询用户订阅是否有效
    */
    function isActive(address user)
        external
        view
        returns (bool)
    {

        Subscription memory s = subscriptions[user];

        return (
            block.timestamp < s.expiry &&
            !s.paused
        );
    }
}
