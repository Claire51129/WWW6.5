//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SubscriptionStorageLayout } from "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV2 is SubscriptionStorageLayout {
  function addPlan(uint8 planId, uint256 price, uint256 duration) external {
    planPrices[planId] = price;
    planDurations[planId] = duration;
  }

  function subscribe(uint8 planId) external payable {
    require(planPrices[planId] > 0, "Plan does not exist");
    require(msg.value == planPrices[planId], "Incorrect payment amount");

    Subscription storage s = subscriptions[msg.sender]; 
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

  function pauseAccount(address user) external {
    subscriptions[user].paused = true;
  }

  function resumeAccount(address user) external {
    subscriptions[user].paused = false;
  }
}