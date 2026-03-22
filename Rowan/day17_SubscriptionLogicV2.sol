// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

/*
    V2 逻辑合约

    在 V1 基础上增加功能：
    - 暂停账户
    - 恢复账户
*/

contract SubscriptionLogicV2 is SubscriptionStorageLayout {

    function addPlan(
        uint8 planId,
        uint256 price,
        uint256 duration
    ) external {

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

    /*
        新功能：暂停账户
    */
    function pauseAccount(address user) external {

        subscriptions[user].paused = true;
    }

    /*
        新功能：恢复账户
    */
    function resumeAccount(address user) external {

        subscriptions[user].paused = false;
    }
}
