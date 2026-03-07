// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    // who is selling the thing
    address public owner;
    // what is the thing
    string public item;
    // when the auction end
    uint public auctionEndTime;
    // so far who call the highest price
    address private highestBidder;
    // so far the highest price
    uint private highestBid;
    // is the auction still on going
    bool public isEnd;
    // list: person -> latest & highest bid，默认全为零
    mapping(address => uint) public bids;
    // 曾经出过价的用户集合
    address[] public bidders;
    
    // 初始化
    constructor(string memory _item, uint _biddingTime) {
        // msg.sender 是一个局变量，它提供部署合约的操作者地址
        owner = msg.sender;
        item = _item;
        // 获取当前时间是 block.timestamp
        // 加上拍卖持续的时间就是拍卖结束的时间
        auctionEndTime = block.timestamp + _biddingTime;
        isEnd = false;
    }

    function setStartBid(uint _startBid) external {
        // 只有合约的拥有者才能设置起拍价
        require(msg.sender == owner, "Only owner can set start bid.");
        // 起拍价必须大于零
        require(_startBid > 0, "Start bid must be greater than zero.");
        // 起拍价必须大于当前最高出价
        require(_startBid > highestBid, "Start bid must be greater than highest bid.");
       highestBid = _startBid;
    }

    // 用户出价
    function bid(uint amount) external {
        // 检查时间，确认拍卖是否还在进行
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        // 检查价格，是否比之前价格高（bids
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount;

        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!isEnd, "Auction end already called.");
        isEnd = true;
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }
}