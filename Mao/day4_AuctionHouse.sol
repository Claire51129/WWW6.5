// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//拍卖会：拥有者、产品、拍卖时间、出价人、出价价格
contract AuctionHouse {
      address public owner;
      string public item;
      uint public auctionEndTime;
      address private highestBidder;
      uint private highestBid;
      bool public ended;

      //出价人名单，出价人对应价格映射
      mapping(address=>uint) public bids;
      address [] public bidders;

      //构造函数，拥有者、拍卖产品、结束时间
      constructor(string memory _item ,uint _biddingTime){
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
      }

      //出价，external只能外部调用，内部调用this，external函数，参数存在区块链的只读区域
      //external 函数：参数存在 calldata（区块链的只读数据区），这个区域读取成本极低，而且用完就释放，不占内存；
      //public 函数：参数存在 memory（合约临时内存），读取 / 存储成本比 calldata 高很多，尤其是参数是大数组时（比如 getAllBidders() 返回的地址数组）。
      function bid(uint amount) external {
        //时间没有截至
        require(block.timestamp < auctionEndTime,"Auction has already ended.");
       //金额大于0
       require(amount > 0 ,"Bid amount must be greater than zero.");
       //金额大于最大价格
       require(amount > bids[msg.sender],"Bid amount must be greater than your previous bid.");

       //拍卖价格为0
       if(bids[msg.sender] == 0){
        bidders.push(msg.sender);
       }

       bids[msg.sender] = amount;

      //更新最大拍卖价格
      if(amount > highestBid){
        highestBid = amount;
        highestBidder = msg.sender;
      }
      }

     //拍卖结束
     function endAuction() external{
        require(block.timestamp >= auctionEndTime,"Auction hasn't ended yet.");
        require(!ended,"Auction has already ended.");
        ended = true;
     }

     //查看获胜者以及金额,虽然highestBidder,highestBid私有，这样提供一个对外的接口可以查看
     function getWiner() external view returns(address,uint){
        require(ended,"Auction has not ended yet");
        return(highestBidder,highestBid);
     }
    
    //查看所有的出价者
    function getAllBidders() external  view returns (address[] memory){
        return bidders;
    }

      }