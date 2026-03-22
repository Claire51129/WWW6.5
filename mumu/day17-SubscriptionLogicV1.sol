// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17-SubscriptionStorageLayout.sol";

/**
  @notice 订阅逻辑合约v1
 */

 contract SubscriptionLogicV1 is SubscriptionStorageLayout{

    // add plan
    function addPlan(uint8 _planId, uint256 _price, uint256 _duration)external{
        planPrices[_planId] = _price;
        planDuration[_planId] = _duration;
    }

    // subcribe
    function subscribe(uint8 _planId) external payable{
        require(planPrices[_planId] >0, "Invalid plan");
        require(msg.value >= planPrices[_planId], "Insufficient payment");

        // 需要修改已有数据，使用storage
        Subscription storage s = subscriptions[msg.sender];

        if (block.timestamp < s.expiry){
            s.expiry += planDuration[_planId];
        }else{
            s.expiry = block.timestamp + planDuration[_planId];
        }

        s.planId = _planId;
        s.paused = false;
    }

    // isActive
    function isActive(address _user) external view returns(bool){
        Subscription memory s = subscriptions[_user];
        return (block.timestamp < s.expiry && !s.paused);
    }
 }