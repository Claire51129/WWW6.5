//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner; //拍卖行老板地址
    string public item; //拍卖物品名称
    uint public auctionEndTime; //拍卖结束时间
    address public highestBidder; //当前最高出价者地址
    uint public highestBid; //当前最高出价金额
    bool public ended; //拍卖是否结束

    mapping (address => uint) public bids; //记录每个地址的出价金额
    address[] public bidders; //记录所有出价者地址

    //构造函数，部署合约时设置拍卖物品名称和拍卖持续时间
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender; //部署合约的地址成为拍卖行老板
        item = _item; //设置拍卖物品名称
        auctionEndTime = block.timestamp + _biddingTime; //设置拍卖结束时间
    }

    function bid(uint amount) external  {
        require(block.timestamp < auctionEndTime,"Auction has already ended"); //检查拍卖是否结束
        require(amount > 0,"Bid amount must be greater than zero."); //检查出价金额是否大于0
        //这里会不会有问题，是和当前最高出价比较，还是和自己之前的出价比较？只是大于自己之前出价也可以比吗？
        require(amount > highestBid,"Bid too low."); //检查新出价是否高

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender); //如果是新出价者，记录其地址
        }

        bids[msg.sender] = amount; //更新出价金额

        if (amount > highestBid) {
            highestBid = amount; //更新最高出价金额
            highestBidder = msg.sender; //更新最高出价者地址
        }

        
    }



    function endAuction() external {
        require(block.timestamp >= auctionEndTime,"Auction hasn't ended yet."); //检查拍卖是否结束
        require(!ended,"Auction end already called."); //检查拍卖是否已经结束")
        require(msg.sender == owner,"Only the auction owner can end the auction."); //检查调用者是否是拍卖行老板

        ended = true; //标记拍卖结束
        
    }

    function getAllBidders() external view returns (address[] memory) {
        return bidders; //返回所有出价者地址
        
    }

    function getWinner() external view  returns (address ,uint) {
        require(ended,"Auction has not ended yet.");//检查拍卖是否结束
        return (highestBidder, highestBid);
    }
    








}