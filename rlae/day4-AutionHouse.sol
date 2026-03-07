// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse{
    address public owner;
    string public item;
    uint public auctionendtime;
    address private highestbidder;
    uint private highestbid;
    uint public startbid;
    bool public ended;
    mapping (address=> uint) public bids;
    address[]public bidders;
    constructor(string memory _item,uint _biddingtime,uint _startbid){
        owner=msg.sender;
        item=_item;
        startbid=_startbid;
        auctionendtime=block.timestamp+_biddingtime;
    }
    function bid(uint amount)external {
        require(block.timestamp < auctionendtime, "Auction already ended");
        require(amount>0);
        require(amount>startbid,"higher price > statbid ");//>startbid
        require(amount>bids[msg.sender]);
        require(amount>highestbid*105/100,"higher price > highset 105% ");// >5%;
        if (bids[msg.sender]==0){
            bidders.push(msg.sender);
        }
        bids[msg.sender]=amount;
        if (amount>highestbid) {
            highestbid=amount;
            highestbidder=msg.sender;
        }
    }
    function endAuction()external{
        require(block.timestamp>auctionendtime,"Auction has not end yet");
        require(!ended,"Auctions ended already called" );
        ended=true;

    }
    function getWinner ()external view returns(address,uint){
        return (highestbidder,highestbid);
    }
    function getallbidders()external view returns(address[] memory){
        return bidders;
    }




}