// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract FriendPlugin{
    mapping(address => address[])public friends;

    function addFriend(address user,address newFriend)public{
        require(newFriend != address(0), "Friend not existed");
        friends[user].push(newFriend);
    }

    function getFriendList(address user)public view returns(address[] memory){
        return friends[user];
    }

    function friendCount(address user)view public returns(uint8){
        return uint8(friends[user].length);
    }
} 