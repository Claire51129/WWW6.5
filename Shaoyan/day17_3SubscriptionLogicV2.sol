// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day17_2SubscriptionLogicV1.sol";

contract SubscriptionLogicV2 is SubscriptionStorageLayout {
    function pauseSubscription() external {
        Subscription storage s = subscriptions[msg.sender];
        require(s.expiry > 0, "No subscription");
        require(!s.paused, "Already paused");

        s.paused = true;
    }

    function resumeSubscription() external {
        Subscription storage s = subscriptions[msg.sender];
        require(s.expiry > 0, "No subscription");
        require(s.paused, "Not paused");

        s.paused = false;
    }

    function getSubscription(address user)
        external
        view
        returns (
            uint8 planId,
            uint256 expiry,
            bool paused
        )
    {
        Subscription storage s = subscriptions[user];
        return (s.planId, s.expiry, s.paused);
    }
}