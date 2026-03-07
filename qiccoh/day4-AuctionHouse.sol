// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse{
    address public owner;
    string public item;
    uint public auctionEndTime;

    address private highestBidder;
    uint private highestBid;

    bool public ended;

    mapping(address => uint) public bids;
    address[] public bidders;
    //
    
   //msg.sender  是一个全局变量——它给我们提供部署合约的操作者地址
    constructor(string memory _item, uint _biddingTime) {
    owner = msg.sender;
    item = _item;
    auctionEndTime = block.timestamp + _biddingTime;
    // _biddingTime 拍卖持续的时间
}

    function bid(uint amount) external {
        //require() 来设置规则——如果规则失败，函数会立即停止。
        require(block.timestamp < auctionEndTime,"time already");
        require(amount >bids[msg.sender],"you must higher than before");
        require(amount > 0 ,  "every bid must >0");
// 判断是否第一次
        if(bids[msg.sender] == 0){
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount;

        if (amount > highestBid){
            highestBid = amount;
            highestBidder = msg.sender;
        }
      
        
    }

    function endAuction() external {
        require(block.timestamp >= auctionEndTime,"Auction hasn't ended yet.");
        require(!ended,"bid is already over");
        ended = true;
       
    }

    function getWinner() external view returns (address, uint) {
    require(ended, "still ");
    return (highestBidder, highestBid);
}
    //想查看所有出价者
    function getAllBidders() external view returns (address[] memory) {
    return bidders;
    }
     


}