// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Day17_SubscriptionStorageLayout {
    address public logicContract; // Keep state variable but dont include any function
    address public owner; // keep the owner

    struct Subscription {
        uint8 planId;
        uint256 expiry; //Timestamp
        bool paused; // If the user has paused the subscription
    }

    mapping(address => Subscription) public subscriptions; //Every user have their subscription
    mapping(uint8 => uint256) public planPrices; //Prices of the subscription
    mapping(uint8 => uint256) public planDuration; // Duration of the subscription
}
