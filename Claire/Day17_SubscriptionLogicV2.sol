// SPDX-License-Identifier: MIT
// 代码开源协议

pragma solidity ^0.8.0;
// 指定Solidity编译器版本

import "./Day17_SubscriptionStorageLayout.sol";
// 导入存储布局合约
// 继承后获得所有存储变量（与V1完全相同）

contract SubscriptionLogicV2 is SubscriptionStorageLayout {
// 定义一个合约，叫"订阅逻辑V2"
// 继承 SubscriptionStorageLayout，数据布局与V1完全一致
// 这是V1的升级版本，新增了暂停/恢复功能

    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
    // 函数：添加/修改套餐（与V1相同）
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
    // 函数：订阅套餐（与V1相同）
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false;  // 订阅时自动激活账户
    }

    function isActive(address user) external view returns (bool) {
    // 函数：检查订阅是否有效（与V1相同）
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    function pauseAccount(address user) external {
    // 🆕 V2新增功能：暂停用户的订阅
    // address user：要暂停的用户地址
    // 作用：管理员可以暂停违规用户的订阅
        
        subscriptions[user].paused = true;
        // 把用户的paused状态设为true
        // 暂停后，isActive()会返回false
        // 但到期时间不变，恢复后还能继续使用剩余时长
    }

    function resumeAccount(address user) external {
    // 🆕 V2新增功能：恢复用户的订阅
    // address user：要恢复的用户地址
    // 作用：暂停期结束后，恢复用户的订阅
        
        subscriptions[user].paused = false;
        // 把用户的paused状态设为false
        // 恢复后，如果还没到期，isActive()会返回true
    }
}