//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

//*highestBidder和highestBid的可见性设置为private，是为了实现【拍卖结束后，public才能查看最高竞价信息】，后面会通过公开函数来添加此逻辑
contract AuctionHouse {
    address public owner;
    string public item;
    uint public auctionEndTime;
    address private highestBidder; //Winner is private, accessible via getWinner
    uint private highestBid; //Highest bid is private, accessible via getWinner
    bool public ended;
    mapping(address => uint) public bids;
    address[] public bidders;

    //Initialize the auction with an item and a duration
    //constructor 是只在合约部署时执行一次的函数，用来初始化状态变量，不能再次调用。
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    //Allow users to place bids
    //function 是合约的主要逻辑代码，用户或其他合约可以调用 function。
    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");
        //Track new bidders. 如果该用户的bids为0，则把他加到bidders数组末尾；防止重复登记。
        //单等号是赋值运算符，作用是改变左边变量的值。双等号是比较运算符，作用是判断左右两边是否相等。
        if(bids[msg.sender]==0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] = amount;

        //Update the highest bid and bidder（默认第一个出最高价的人）
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    //End the auction after the time has expired
    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet.");
        require(!ended, "Auction end already called."); //避免重复调用，浪费gas费或重复触发后续函数
        ended = true;
    }

    //Get a list of all bidders
    //最初的address[] public bidders已经将bidders数组声明为public，但Solidity 自动生成的 getter 函数强制要求你输入一个索引（Index），即你只能获取第0位/第1位/...投标者的名字，不支持一次性返回整个数组。而getAllBidders()函数通过显式写出 returns (address[] memory)告诉 Solidity以整个数组格式返回，而不仅仅是数组中的一个元素。 
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    //Retrieve winner and their bid after auction ends
    function getWinner() external view returns(address, uint) {
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    } 
}

//关于external vs public
//如果一个函数确定不会被合约内部的其他函数调用，将其设为 external 会比 public 更省钱，更高效。
//当你调用一个函数并传入参数时，EVM（以太坊虚拟机）需要决定把这些参数存在哪里。
//public 函数：为了让合约内部也能调用它，编译器会强制将参数从 calldata（只读、最便宜的临时空间）复制到 memory（可读写、较贵的空间）。这个“复制”动作需要消耗额外的 Gas。
//external 函数：它默认直接从 calldata 读取参数，不需要进行昂贵的复制操作。

