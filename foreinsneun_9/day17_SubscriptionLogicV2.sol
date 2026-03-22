// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day17_SubscriptionStorageLayout.sol";
import "./day17_SubscriptionLogicV1.sol";
contract SubscriptionLogicV2 is SubscriptionStorageLayout, SubscriptionLogicV1 {
    function pauseAccount(address user) external {
        subscriptions[user].paused = true;
    }

    function resumeAccount(address user) external {
        subscriptions[user].paused = false;
    }
}