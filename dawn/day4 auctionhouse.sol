// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auctionhouse {
    address public owner;
    string public item;
    uint public auctionendtime;
    address private highestbidder;
    uint private highestbid;
    bool public ended;

    mapping(address => uint) public bids;
    address [] public bidders;
    
    constructor (string memory _item,uint _biddingtime){
        owner = msg.sender;
        item = _item;
        auctionendtime = block.timestamp + _biddingtime;
    }

    function bid(uint amount) external {
        require(block.timestamp < auctionendtime, "auction has already ended");
        require(amount > 0, "bid amount must be greater than zero.");
        require (amount > bids[msg.sender], "new bid must be higher than your current bid.");

        if (bids [msg.sender] == 0 ) {
            bidders.push(msg.sender);
        } 
        bids[msg.sender] = amount;

        if (amount > highestbid) {
            highestbid = amount;
            highestbidder = msg.sender;

        }
    }

    function endauction() external {
        require (block.timestamp >= auctionendtime, "auction hasn't ended yet.");
        require (!ended, "auction end already called");

        ended = true;
    }

    // get list of all bidders
    function getallbidders()external view returns (address [] memory) {
        return bidders;
    }

    //retrive winner and their bid after auction ends
    function getwinner() external view returns (address, uint) {
        require(ended, "auction has not ended yet.");
        return (highestbidder, highestbid);
    }
}
