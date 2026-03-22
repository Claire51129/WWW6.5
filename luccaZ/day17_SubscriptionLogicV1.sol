//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SubscriptionStorageLayout } from "./day17_SubscriptionStorageLayout.sol";
//this one is the logic contract, it will contain the business logic 
//and can be upgraded without changing the state variables

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
  function addPlan(uint8 planId, uint256 price, uint256 duration) external {
    planPrices[planId] = price;
    planDurations[planId] = duration;
  }

  function subscribe(uint8 planId) external payable {
    require(planPrices[planId] > 0, "Plan does not exist");
    require(msg.value == planPrices[planId], "Incorrect payment amount");

    Subscription storage s = subscriptions[msg.sender]; 
    //not use memory because we need to update the subscription in storage
    if (block.timestamp < s.expiry) {
      s.expiry += planDurations[planId]; //extend the subscription if it's still active
    } else {
      s.expiry = block.timestamp + planDurations[planId]; //start a new subscription
    }

    s.planId = planId;
    s.paused = false;
  }

  function isActive(address user) external view returns (bool) {
    Subscription memory s = subscriptions[user];
    return (block.timestamp < s.expiry && !s.paused);
  }
}