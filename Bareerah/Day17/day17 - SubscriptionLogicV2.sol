// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17 - SubscriptionStorageLayout.sol";


// 相比 V1 增加了暂停/恢复功能
contract SubscriptionLoginV1 is SubscriptionStorageLayout{
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage s = subscription[msg.sender];
        if(block.timestamp < s.expiry){
            s.expiry += planDuration[planId];
        }else{
            s.expiry = block.timestamp + planDuration[planId];
        }
        s.planId = planId;
        s.paused = false;
    }

    function isActive(address user) external view returns(bool){
        Subscription memory s = subscription[user];
        return (block.timestamp < s.expiry && !s.paused);
    }

    // 新增暂停功能
    function pauseAccount(address user) external {
        subscription[user].paused = true;
    }
    
    // 新增恢复功能
    function resumeAccount(address user) external {
        subscription[user].paused = false;
    }
}