// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AuctionHouse
{
    address public owner;
    string public item;
    uint public auction_endtime;
    address private highestbidder;
    uint private highestbid;
    bool public ended;
    mapping(address=>uint)public bids;
    address[] public bidders;

    constructor(string memory _item,uint _biddingtime)
    {
        owner=msg.sender;
        item=_item;
        auction_endtime=block.timestamp+_biddingtime;
    }

    function bid(uint amount)external
    {
        require(block.timestamp<auction_endtime,"Auction has already ended.");
        require(amount>0,"Bid amount must be greater than zero.");
        require(amount>bids[msg.sender],"New bid must be higher than your current bid.");

        if(bids[msg.sender]==0)
        {
            bidders.push(msg.sender);
        }
        bids[msg.sender]=amount;

        if(amount>highestbid)
        {
            highestbid=amount;
            highestbidder=msg.sender;
        }
    }

    function end_auction()external 
    {
        require(block.timestamp>=auction_endtime,"Auction hasn't ended.");
        require(!ended,"Auction end already called.");
        ended=true;
    }

    function get_winner()external view returns(address,uint)
    {
        require(ended,"Auction has not ended yet.");
        return(highestbidder,highestbid);
    }

    function get_allbidders()external view returns(address[]memory)
    {
        return bidders;
    }
}
