// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SubscriptionStorageLayout} from "./day17-SubscriptionStorageLayout.sol";

contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

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

    function isActive(address user) external view returns (bool) {
        Subscription memory s = subscriptions[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    //暂停用户功能
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }
    
    //恢复用户功能
    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}

// V2不能改变量顺序，否则数据会乱
// 【用户调用subscribe()】 ①用户调用proxy；②proxy没有subscribe；③fallback触发；④delegatecall → LogicV1; ⑤LogicV1执行； ⑥数据写进Proxy
// 【升级流程】 ①部署LogicV2; ②调用upgradeTo(V2地址)；③所有用户自动用新功能；④数据完全不变
// V2 logic：0xDA07165D4f7c84EEEfa7a4Ff439e039B7925d3dF