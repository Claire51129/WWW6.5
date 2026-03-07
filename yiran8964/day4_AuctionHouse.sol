//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    //发起者
    address public owner;
    //竞拍的商品
    string public item;
    //竞拍持续的时间
    uint public auctionEndTime;
    //商品的最低价格
    uint public lowestPrice;

    address private highestBidder;
    uint private highestBid;
    bool public ended;

    mapping (address => uint) public bids;
    address[] public bidders;

    event InfoBid(address bidder, uint bid);

    constructor(string memory _item, uint _biddingTime, uint _lowestPrice){
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
        lowestPrice = _lowestPrice;
    }

    function extendTime(uint _extendAuctionTime) external {
        auctionEndTime = block.timestamp + _extendAuctionTime;
    }

    // function bid(uint amount) external {
    //     //拍卖人不能进行竞拍
    //     require(msg.sender != owner, "bidder can't be owner");
    //     require(block.timestamp < auctionEndTime, "Auction has ended");
    //     require(amount > highestBid, "Bid too low");

    //     if (bids[msg.sender] == 0) {
    //         bidders.push(msg.sender);
    //     }

    //     bids[msg.sender] += amount;

    //     if (bids[msg.sender] > highestBid) {
    //         highestBid = bids[msg.sender];
    //         highestBidder = msg.sender;
    //     }
    // }

    function bid() external payable {
        require(msg.sender != owner, "bidder can't be owner");
        require(block.timestamp < auctionEndTime, "Auction ended");
        require(msg.value > highestBid, "Bid too low");
        //限制最低出价
        require(msg.value > lowestPrice,"Bid too low");

        emit InfoBid(msg.sender, msg.value);

        //退款给之前的最高出价者
        if (highestBidder != address(0)) {
            (bool success,) = payable(highestBidder).call{value: highestBid}("");
            require(success, "Transfer failed");
        }

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = msg.value;

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdraw() external {
        require(ended, "Auction not ended");
        require(msg.sender == owner, "Not owner");

        (bool success,) = payable(owner).call{value: highestBid}("");
        require(success, "Transfer failed");
    }

    function endAuction() external {
        require(!ended, "Auction already ended");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(msg.sender == owner, "Only owner can end");

        ended = true;
    }

    function getWinner() external view returns(address, uint) {
        require(ended, "Auction not ended");
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns(address[] memory) {
        return bidders;
    }
}