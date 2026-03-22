// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day17_SubscriptionStorageLayout.sol";

contract SubscriptionLogicV2 is SubscriptionStorageLayout {

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function addPlan(uint8 _planId, uint256 _priceWei, uint256 _durationSeconds) external onlyOwner {
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

    function pauseAccount(address _user) external onlyOwner {
        subscriptions[_user].paused = true;
    }

    function resumeAccount(address _user) external onlyOwner {
        subscriptions[_user].paused = false;
    }

    function cancelSubscription() external notPaused {
        require(subscriptions[msg.sender].expiry > block.timestamp, "No active subscription");
        subscriptions[msg.sender].expiry = block.timestamp;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }
}
