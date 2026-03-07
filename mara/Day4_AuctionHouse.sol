// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner;
    string public item;
    uint public autionEndTime;
    
    address private highestBidder;
    uint private highestBid;

    bool public ended;
    mapping(address => uint) public bids;
    address[] public bidders;

    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        autionEndTime = block.timestamp + _biddingTime;
    }
    function bid(uint amount) public {
        require(amount > 0);
        require(block.timestamp < autionEndTime);
        require(amount > bids[msg.sender]);

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
        require(block.timestamp >= autionEndTime);
        require(!ended);
        ended = true;
    }
    function getWinner() public view returns (address, uint) {
        require(ended);
        return (highestBidder, highestBid);
    }
    function getAllBidders() public view returns (address[] memory) {
        return bidders;
    }
}