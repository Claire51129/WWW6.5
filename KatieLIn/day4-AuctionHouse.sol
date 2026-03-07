// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract AuctionHouse{

    address public owner;
    string public item;
    uint public auctionEndTime;
    uint public startingPrice;
    address private highestBidder;
    uint private highestBid;
    bool public ended;

    mapping (address => uint) public bids;
    address[] public bidders;

    constructor(
        string memory _item, 
        uint _biddingTime,
        uint _startingPrice
    ){
        owner = msg.sender;
        item =_item;
        auctionEndTime = block.timestamp +_biddingTime;
        startingPrice = _startingPrice;
        highestBid = _startingPrice;
    }

    function bid (uint amount) external {
        require(block.timestamp < auctionEndTime,"Auction has already ended.");
        require(amount>0, "Bid amount must be greater than zero.");
        uint minRequiredBid = highestBid + (highestBid * 5) / 100;
        require(
            amount>= minRequiredBid,
            "New bid must be at least 5% higher than current highest bid.");

        if (bids[msg.sender]==0){
            bidders.push(msg.sender);
        }

        bids[msg.sender]+=amount;

        if(amount> highestBid){
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }
    function endAuction() external {
        require(block.timestamp >= auctionEndTime,"Auction hasn't ended yet.");
        require(!ended,"Auction end already called.");

        ended= true;
    }

    function withdraw() external {
        require(ended, "Auction not ended yet.");
        require(msg.sender !=highestBidder, "Winner cannot withdraw.");

        uint amount = bids[msg.sender];
        require(amount > 0, "Nothing to withdraw.");

        bids[msg.sender] = 0;
    }

    function getAllBidders() external view returns (address[] memory){
        return bidders;
    }

    function getWinner() external view returns (address,uint){
        require(ended,"Auction has not ended yet.");
        return (highestBidder,highestBid);
    }
    
}