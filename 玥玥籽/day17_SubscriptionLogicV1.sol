// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function addPlan(uint8 _planId, uint256 _priceWei, uint256 _durationSeconds) external {
        require(_priceWei > 0, "Price must be positive");
        require(_durationSeconds > 0, "Duration must be positive");
        planPrices[_planId] = _priceWei;
        planDuration[_planId] = _durationSeconds;
    }

    function subscribe(uint8 _planId) external payable notPaused {
        require(planPrices[_planId] > 0, "Plan does not exist");
        require(msg.value >= planPrices[_planId], "Insufficient payment");

        Subscription storage s = subscriptions[msg.sender];

        if (block.timestamp < s.expiry) {
            s.expiry += planDuration[_planId];
        } else {
            s.expiry = block.timestamp + planDuration[_planId];
        }

        s.planId = _planId;
        s.paused = false;
    }

    function isActive(address _user) external view returns (bool) {
        Subscription memory s = subscriptions[_user];
        return block.timestamp < s.expiry && !s.paused;
    }

    function getExpiry(address _user) external view returns (uint256) {
        return subscriptions[_user].expiry;
    }
}
