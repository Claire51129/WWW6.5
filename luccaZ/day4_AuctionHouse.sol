//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner;
    string public item;
    uint public auctionEndTime;
    address private highestBidder;
    uint private highestBid;
    bool public ended;

    mapping(address => uint) public bids;
    address[] public bidders;

    constructor(string memory _item, uint _biddingTime, uint _startPrice) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
        highestBid = _startPrice;
    }

    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");
        require(amount > (highestBid * 105) / 100, "New bid must be 5% higher than the highest bid amount.");

        //add new bidder
        if(bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] = amount;
        if(amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!ended, "Auction end already called.");
        ended = true;
    }

    function getWinner() external view returns (address, uint) {
        require(ended, "Auction has not ended yet");
        return(highestBidder, highestBid);
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    function withdraw() external {
        require(ended, "Auction has not ended yet.");
        require(msg.sender != highestBidder, "Winner cannot withdraw their bid.");
        uint amount = bids[msg.sender];
        require(amount > 0, "Nothing to withdraw.");
        bids[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed.");
    }
}



