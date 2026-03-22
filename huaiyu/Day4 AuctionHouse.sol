// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner;
    string public item;
    uint public auctionEndTime;
    address private highestBidder; // Winner is private, accessible via getWinner
    uint private highestBid;       // Highest bid is private, accessible via getWinner
    bool public ended;
    address public itemOwner;

    mapping(address => uint) public bids;
    address[] public bidders;

    // Initialize the auction with an item and a duration
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        itemOwner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // Allow users to place bids
    function bid(uint amount) external payable {
        require(!ended, "Auction has ended.");
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");
        require(msg.value == amount, "Sent value must equal bid amount.");

        // Track new bidders
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        // Record previous highest bidder for refund
        address previousHighestBidder = highestBidder;
        uint previousHighestBid = highestBid;

        bids[msg.sender] = amount;

        // Update the highest bid and bidder
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;

            // Refund the previous highest bidder if different
            if (previousHighestBid > 0 && previousHighestBidder != address(0) && previousHighestBidder != highestBidder) {
                (bool success, ) = payable(previousHighestBidder).call{value: previousHighestBid}("");
                require(success, "Refund transfer failed");
            }
        }
    }

    // End the auction after the time has expired
    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!ended, "Auction end already called.");

        ended = true;

        // Transfer item ownership and funds if there is a winner
        if (highestBid > 0) {
            itemOwner = highestBidder;
            (bool success, ) = payable(owner).call{value: highestBid}("");
            require(success, "Payment transfer failed");
        }
    }

    // Get a list of all bidders
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    // Retrieve winner and their bid after auction ends
    function getWinner() external view returns (address, uint) {
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }

    // Withdraw funds after auction ends
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw.");
        require(ended, "Auction has not ended yet.");
        if (address(this).balance > 0) {
            (bool success, ) = payable(owner).call{value: address(this).balance}("");
            require(success, "Withdraw transfer failed");
        }
    }
}