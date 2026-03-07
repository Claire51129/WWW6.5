// SPDX-License-Identifier: MIT
//版权声明。这个代码是开源的（MIT 协议）
pragma solidity ^0.8.0;
//规定语言版本，告诉电脑“请用 0.8.0 以上版本的 Solidity 语法来读这篇剧本。”
contract AuctionHouse {
    //建立一栋大楼“AuctionHouse”，大括弧后面的所有内容都是“AuctionHouse"里的
    address public owner;
    //老板的钱包地址，public 公开可见
    string public item;
    //拍品名字，公开可见
    uint public auctionEndTime;
    //数字，拍卖结束时间，公开可见
    address private highestBidder;
    //暗拍，不公开目前的“最高出价人”
    uint private highestBid;
    //暗拍，不公开目前的“最高价格”
    bool public ended;
    //bool (布尔类型): 数据类型，只有true或者false。false 就是营业中，如果是 true 就是已打烊。
    mapping(address => uint) public bids;
    //这是一个映射（计票器）。只要输入观众的钱包地址，立刻就能查出他今天在这个场地里总共投了多少钱。
    address[] public bidders;
    //这是一个数组（名单）。所有举过牌、出过价的观众，都会排队记录在这个长长的名单里。
    
    //这部分代码在这个合约的一生中，只在部署的那一秒钟运行一次。
    constructor(string memory _item, uint _biddingTime) {
        //拍品名字（_item）和拍卖打算开多少秒（_biddingTime）。
        owner = msg.sender;
        //系统自动识别按下部署按钮的人（msg.sender），并把“老板”的头衔颁给你
        item = _item;
        //把填好的拍品名字写到告示牌上
        auctionEndTime = block.timestamp + _biddingTime;
    }
    //未来的绝对时间戳=当前区块时间戳+竞拍持续秒数
    
    function bid(uint amount) external {
        //按下出价按钮，amount 就是他这次要加多少钱
        require(block.timestamp < auctionEndTime, "Auction ended");
        require(amount > highestBid, "Bid too low");
        //require 括号里的第一个条件，写的是你“希望看到的好结果”，而后面的文字，写的是“没达到这个结果时的糟糕原因”它把“检查条件”和“报错”写在了一行
        //“当下时间早于拍卖结束时间，拍卖结束”“一个人出的总价大于最高的出价”，“价格太低”
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        //查计票器。如果这个人以前出价是 0（说明是新面孔），就把他的名字加到（push）观众总名单的最末尾
        
        bids[msg.sender] += amount;
        //在计票器上，把这个观众这次出的钱，累加（+=）到他的名下
        if (bids[msg.sender] > highestBid) {
            highestBid = bids[msg.sender];
            highestBidder = msg.sender;
        }
    }
    //如果他累加后的总出价，超过了最高价，就把私密里的“最高价”和“最高出价人”的记录更新成ta
    
    function endAuction() external {
        require(!ended, "Auction already ended");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(msg.sender == owner, "Only owner can end");
    //关门。三个保安必须同时放行：门没关过 + 倒计时确实结束了 + 必须是老板本人操作。
        ended = true;
    }
   //老板亲自把门口的营业牌翻到 true（已打烊）
    
    function getWinner() external view returns (address, uint) {
        require(ended, "Auction not ended");
        return (highestBidder, highestBid);
    }
    //观众来查结果。裁判拦住说：“必须等营业牌变成已打烊（ended）才能查”。如果打烊了，裁判就打开私密抽屉，把赢家是谁、出了多少钱，这两个结果一起退还（return）给你。
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }//任何人都可以按这个按钮，向系统索要那份长长的参赛者数组名单。
}