 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SubscriptionStorageLayout} from "./day17_SubscriptionStorageLayout.sol";

//第二个逻辑合约：允许用户添加或更新订阅套餐，且带有套餐暂停/恢复功能
contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }
    //和V1一样
    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];
        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[planId];
        } else {
            s.expiry = block.timestamp + planDuration[planId];
        }

        s.planId = planId;
        s.paused = false;
    }
    //检查订单是否过期或暂停，返回true则说明未过期未暂停
    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }
    //暂停用户的账户，可以由管理员使用，或者在未来的版本中委托给用户自己使用。
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
    //重新启用已暂停的订阅
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}

