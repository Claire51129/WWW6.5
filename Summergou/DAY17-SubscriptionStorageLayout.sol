//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract SubscriptionStorageLayout{
    address public logicContract;
    address public owner;

    //the iformation of Subscription
    struct Subscription{
        uint8 planID;
        uint256 expiry;
        bool paused;
    }

    //the mappings 
    mapping(address => Subscription) subscriptions;
    mapping(uint8 => uint256) planPrices;
    mapping(uint8 => uint256) planDuration;


}
