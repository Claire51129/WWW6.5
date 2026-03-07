// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse{
    address public owner;
    string public item;
    uint public auctionEndTime;
    address private highestBidder;
    uint private highestBid;
    bool public ended;

    mapping(address => uint ) public bids;
    mapping(address => bool) public hasRefunded;
    address[] public bidders;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint winningBid);
    event RefundProcessed(address indexed bidder, uint amount);

    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() external payable {
        require(block.timestamp < auctionEndTime, "Auction ended");
        require(msg.value > 0, "Bid amount must be greater than 0");
        uint totalBid = bids[msg.sender] + msg.value;
        require(totalBid > highestBid, "Bid too low");


        if (bids[msg.sender] == 0) { // Fixed the assignment operator
            bidders.push(msg.sender);
        }

        bids[msg.sender] += totalBid;

        if (bids[msg.sender] > highestBid) {
            highestBid = bids[msg.sender];
            highestBidder = msg.sender;
        }
    }

    function endAuction() external {
        require(!ended,"Auction already ended");
        require(block.timestamp >= auctionEndTime,"Auction not yet ended");
        require(msg.sender == owner,"Only owner can end");

        ended = true;
    }
    function claimRefund() external {
        require(ended, "Auction not yet ended");
        require(msg.sender != highestBidder, "Winner cannot claim refund");
        require(bids[msg.sender] > 0, "No bid to refund");
        require(!hasRefunded[msg.sender], "Already refunded");


    uint refundAmount = bids[msg.sender];
    
    hasRefunded[msg.sender] = true;

    bids[msg.sender] = 0;

    (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
    require(success, "Refund transfer failed");

    emit RefundProcessed(msg.sender, refundAmount);
}

    function getWinner() external view returns (address, uint) {
        require(ended,"Auction not ended");
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    function withdrawProceeds() external {
        require(ended, "Auction not ended");
        require(msg.sender == owner, "Only owner can withdraw proceeds");
        
        uint amount = highestBid;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer to owner failed");
    }

    function refund() external {
        require(ended, "Auction not ended");
        require(msg.sender != highestBidder, "Winner cannot refund");
        
        uint amount = bids[msg.sender];
        require(amount > 0, "No bid to refund");

        bids[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Refund failed");
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        revert("Please use bid() function to place your bid");
    }
}