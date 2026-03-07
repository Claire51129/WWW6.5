// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse{

    //定义变量
    address public owner; //新内容：address类型是存储钱包地址的变量类型
    string public item;  //价格是整数
    uint public auctionEndTime;
    address private highestBidder; //出价最高的人的钱包地址要隐藏
    uint private highestBid ;       //最高价要隐藏，我层初始化了一下，一开始最高价肯定是0；但是老师也没写，应该是有理由：比如节约空间
    bool public ended;   //Bool类型，初始化为False

    //钱包地址（竞拍人）跟价格的映射
    mapping(address => uint) bids; //去掉public
    address[] bidders;  //需要一个列表存储所有的竞拍者地址，刚刚我在想要不要弄一个价格array，不用，应为已经有映射了去掉public

    // 合约信息初始化的特别函数constructor只运行一次，前面没有定义biddingTime也是个有意思的节约内存的点，只要函数的argument有参数就能在界面看到输入口
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender; //msg是全局变量，已经在solidity框架里存在的，拿来就用即可
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime; //block的性质也跟msgs一样
    }

    //投标的函数，出现了external这个关键字，说明该函数只能从合约外部调用，Public能从内部、外部调用，external的函数参数存在calldata中，只读
    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");//require 需要**条件，不符合直接停止执行该函数，并发出提示
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        // 如果这个地址的出价是0，说明是新的投标者，要把她的名字加入到列表中
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        //如果不是，则直接修改她地址所对应的出价
        bids[msg.sender] = amount;

        //如果这次输入的价格大于最高出价，则最高出价为此出价，但是highestBid没有初始化？
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }
    // 我点了竞拍才会结束吗？检查时间是否超过竞价时间，
    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");//如果没结束，直接跳出函数
        require(!ended, "Auction end already called.");

        ended = true;
    }

     // 得到竞拍者的名单
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    // 获取拍卖赢家
    function getWinner() external view returns (address, uint) {
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }

}

