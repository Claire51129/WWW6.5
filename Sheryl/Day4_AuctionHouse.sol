// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner;
    string public item;
    uint public auctionEndTime;
    address private highestBidder;
    uint private highestBid;
    bool public ended;
    mapping (address => uint) public bids;
    address[] public bidders;

    // Initialize the auction with an item and a duration
    constructor (string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // Allow users to place bids
    function bid(uint amount) external {
        require(!ended, "Auction has already ended");
        require (block.timestamp < auctionEndTime, "Auction Ended.");
        require (amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        //Track new bidders
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] = amount;

        //Update the highest bidder and bid
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }
    //End the auction
    function endAuction() external {
        require(msg.sender == owner, "Only owner can end auction");
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!ended, "Auction end already called.");

        ended = true;
    }

    //Get a list of all bidders
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    //Retrive the winner and their bid after auction ends
    function getWinner() external view returns(address, uint) {
        require(ended, "Auction hasn't ended yet.");
        return (highestBidder, highestBid);
    }
}

