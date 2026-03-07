// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AuctionHouse {
    // 拍卖发起者
    address public owner;
    // 拍卖物品
    string public item;
    // 拍卖结束时间，比如300=5min
    uint public auctionEndTime;
    // 拍卖是否结束
    bool public ended;
    // 起拍价
    uint public startingBid;
    // 参与者的出价
    mapping(address => uint) private bids;
    // 拍卖参与者
    address[] private bidders;
    // 当前最高价
    uint private highestBid;
    // 当前最高价出价者
    address private highestBidder;

    constructor(string memory _item, uint _biddingTime, uint _startingBid) {
        owner = msg.sender;
        item = _item;
        startingBid = _startingBid;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(msg.value > startingBid, "Bid amount must be greater than starting bid.");
        require(msg.value > bids[msg.sender], "New bid must be higher than your current bid.");

        if (bids[msg.sender] == 0) {
            // 未出价过
            bidders.push(msg.sender);
        }
        bids[msg.sender] = msg.value;

        if (msg.value > highestBid) {
            // 退款给之前的最高出价者
            if (highestBidder != address(0)) {
                payable(highestBidder).transfer(highestBid);
            }
            highestBid = msg.value;
            highestBidder = msg.sender;
        }
    }

    // 允许owner延长拍卖时间
    function extendAuction(uint _extendTime) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(msg.sender == owner, "Only owner can extend Auction");
        auctionEndTime = auctionEndTime + _extendTime;
    }

    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!ended, "Auction end already called.");
        require(msg.sender == owner, "Only owner can end Auction");
        ended = true;
    }

    function withdraw() external payable {
        require(ended, "Auction has not ended yet.");
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(highestBid);
    }

    function getWinner() external view returns (address, uint) {
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

}
