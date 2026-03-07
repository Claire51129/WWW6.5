// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse{
    bool public ended;
    bool public paused;
    uint public auctionEndTime;
    uint private  highestBid;
    address payable private highestBidder;
    address payable public owner;
    string public item;

    mapping (address => uint256) public bidsReturn;
    address[] public bidders;

    constructor(string memory _item, uint _biddingTime){
        owner = payable(msg.sender);
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function getWinner() external view returns (address, uint){
        require(ended, "Auction not ended.");
        return (highestBidder, highestBid);
    }

    function endAuction() external {
        require(msg.sender == owner, "Only owner can call this.");
        require(!ended, "Auction already ended.");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        
        ended = true; 
        (bool success, ) = owner.call{value: highestBid}("");
        require(success, "Transfer to owner failed.");
    }

    function bid() external payable {
        require(!paused, "Contract is paused!");
        require(block.timestamp < auctionEndTime, "Auction ended.");
        require(msg.value >= 0.01 ether, "Bid needs larger than 0.01 ETH.");
        require(msg.value > highestBid, "Bid is too low.");

        if(highestBidder != address(0)){
            bidsReturn[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = payable (msg.sender);
        
        bool exists = false;
        for(uint i=0; i < bidders.length; i++) {
            if(bidders[i] == msg.sender) {
                exists = true;
                break;
            }
        }
        if(!exists) bidders.push(msg.sender);
    }

    function getAllBidders() external view returns (address[] memory){
        return bidders;
    }

    function withdraw() external returns (bool) {
        uint256 amount = bidsReturn[msg.sender];
        if (amount > 0) {
            bidsReturn[msg.sender] = 0;
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            if (!success) {
                bidsReturn[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function togglePause() external {
        require(msg.sender == owner, "Only owner can call this.");
        paused = !paused;
    }

    function extendAuction(uint256 _extraTime) external {
        require(msg.sender == owner, "Only owner can call this.");
        require(!ended, "Auction already ended.");
        auctionEndTime += _extraTime;
    }
}