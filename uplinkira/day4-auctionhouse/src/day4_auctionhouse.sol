// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuctionHouse {
    address public owner;
    string public item;
    uint256 public auctionEndTime;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bids;

    constructor(string memory _item, uint256 _durationSeconds) {
        require(bytes(_item).length > 0, "Item cannot be empty");
        require(_durationSeconds > 0, "Duration must be greater than 0");

        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _durationSeconds;
    }

    function bid(uint256 _amount) public {
        require(!ended, "Auction already ended");
        require(block.timestamp < auctionEndTime, "Auction time is over");
        require(_amount > highestBid, "Bid must be greater than highest bid");

        highestBid = _amount;
        highestBidder = msg.sender;
        bids[msg.sender] = _amount;
    }

    function endAuction() public {
        require(msg.sender == owner, "Only owner can end auction");
        require(!ended, "Auction already ended");
        require(block.timestamp >= auctionEndTime, "Auction is still active");

        ended = true;
    }

    function getWinner() public view returns (address, uint256) {
        require(ended, "Auction not ended yet");
        return (highestBidder, highestBid);
    }
}
