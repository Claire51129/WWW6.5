// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner; //所有者
    string public item; //拍卖品
    uint public auctionEndTime; //拍卖结束时间
    address private highestBidder; //最高出价人地址
    uint private highestBid; //最高出价
    uint private startingBid; //起拍价
    bool public ended; //标记拍卖结束
    
    mapping(address => uint) public bids; //记录每个用户的出价
    address[] public bidders; //至少出价一次的人的名单

    constructor(string memory _item, uint _biddingTime, uint _startingBid) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
        startingBid = _startingBid;
    }

    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender]+10, "New bid must be higher than your current bid.");
        require(amount >= startingBid, "Bid must be at least the starting price.");
        
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount; //更新用户出价
        
        if (amount > highestBid) {
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
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    function withdrawBid() external {
        require(!ended, "Auction has ended, cannot withdraw bids.");
        require(bids[msg.sender] > 0, "No bid to withdraw.");

        // uint amount = bids[msg.sender];
        bids[msg.sender] = 0;

        // Remove from bidders array if this was their only bid
        for (uint i = 0; i < bidders.length; i++) {
            if (bidders[i] == msg.sender) {
                bidders[i] = bidders[bidders.length - 1];
                bidders.pop();
                break;
            }
        }

        // If the withdrawn bid was the highest bid, update highestBid and highestBidder
        if (msg.sender == highestBidder) {
            highestBid = 0;
            highestBidder = address(0);
            // Find the new highest bidder
            for (uint i = 0; i < bidders.length; i++) {
                if (bids[bidders[i]] > highestBid) {
                    highestBid = bids[bidders[i]];
                    highestBidder = bidders[i];
                }
            }
        }
    }
}
