// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //许可声明和指定版本

//定义一个名为 AuctionHouse 的智能合约，合约是 Solidity 中代码的基本容器，类似其他语言的 "class"。
contract AuctionHouse {
    address public owner; //声明一个公共状态变量 owner，类型为 address（以太坊地址类型），public 修饰符会自动生成一个同名的只读 getter 函数，外部可以通过 owner() 获取该值。
    string public item; //用于存储拍卖品的名称
    uint public auctionEndTime; //春促拍卖结束的时间戳（秒)
    address private highestBidder; //声明私有状态变量 highestBidder，类型为 address，存储当前最高出价者的地址。
    //修饰符表示该变量只能在合约内部访问，外部无法直接读取（也不会生成 getter 函数）。
    uint private highestBid; //存储当前最高出价金额（单位：wei，以太坊最小单位）
    bool public ended; //声明公共状态变量 ended，类型为 bool（布尔值），标记拍卖是否已结束（默认值为 false）

    mapping(address => uint) public bids; //声明一个映射（Mapping） 类型的公共状态变量 bids，键是 address（出价者地址），值是 uint（该地址的总出价金额）。
    //映射类似其他语言的哈希表 / 字典，但 Solidity 中映射的键会被哈希处理，且默认值为 0（未赋值的地址对应值都是 0）。
    //public 修饰符会生成 bids(address) 函数，外部可通过地址查询该地址的总出价。
    address[] public bidders; //声明一个动态数组 bidders，存储所有参与出价的地址（类型为 address）。

    constructor(string memory _item, uint _biddingTime) {
        //声明合约的构造函数（constructor），合约部署时只会执行一次，用于初始化状态变量。
        owner = msg.sender; //初始化 owner 为 msg.sender（调用合约部署交易的地址，即合约创建者）
        item = _item; //将构造函数传入的 _item 赋值给状态变量 item，设置拍卖品名称。
        auctionEndTime = block.timestamp + _biddingTime; //计算拍卖结束时间：block.timestamp 是当前区块的时间戳（部署合约时的区块时间），加上拍卖持续时间 _biddingTime，赋值给 auctionEndTime。
    }

    function bid(uint amount) external {
        //声明一个外部函数 bid，用于用户提交出价，参数 amount 是出价金额（uint 类型）。
        //external 修饰符表示该函数只能被外部账户 / 合约调用，不能在合约内部调用（相比 public 更节省 gas）。
        require(block.timestamp < auctionEndTime, "Auction ended"); //require 是 Solidity 中的校验函数：如果条件不满足，会回滚交易并返还剩余 gas，同时抛出指定错误信息。
        //这里校验：当前区块时间 < 拍卖结束时间，否则报错 "Auction ended"（拍卖已结束）。
        require(amount > highestBid, "Bid too low"); //校验：本次出价金额 > 当前最高出价，否则报错 "Bid too low"（出价过低）。
        //注意：这里的逻辑有小问题 —— 实际应校验 bids[msg.sender] + amount > highestBid，否则多次小额出价可能叠加超过最高出价，但原代码直接要求单次 amount 超过最高出价。

        if (bids[msg.sender] == 0) {
            //如果当前出价者（msg.sender）的历史总出价为 0（即首次出价）。
            bidders.push(msg.sender); //将该地址添加到 bidders 数组中（记录首次出价的用户）。
        }

        bids[msg.sender] += amount; //更新该出价者的总出价：历史出价 + 本次出价金额

        if (bids[msg.sender] > highestBid) {
            //判断：如果该用户的总出价超过当前最高出价。
            highestBid = bids[msg.sender]; //更新最高出价为该用户的总出价。
            highestBidder = msg.sender; //更新最高出价者为当前出价者地址。
        }
    }

    function endAuction() external {
        //声明外部函数 endAuction，用于结束拍卖。
        require(!ended, "Auction already ended"); //校验：拍卖未结束（ended 为 false），否则报错 "Auction already ended"（拍卖已结束）。
        require(block.timestamp >= auctionEndTime, "Auction not yet ended"); //校验：当前区块时间 >= 拍卖结束时间，否则报错 "Auction not yet ended"（拍卖尚未结束）。
        require(msg.sender == owner, "Only owner can end"); //校验：调用者必须是合约所有者（msg.sender == owner），否则报错 "Only owner can end"（只有所有者可结束）

        ended = true; //将 ended 标记为 true，表示拍卖已结束
    }

    function getWinner() external view returns (address, uint) {
        //声明一个外部只读函数 getWinner，返回最高出价者地址和最高出价金额。
        require(ended, "Auction not ended"); //校验：拍卖已结束，否则报错 "Auction not ended"（拍卖未结束）。
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns (address[] memory) {
        //明外部只读函数 getAllBidders，返回所有出价者的地址数组。
        return bidders; //返回值类型是 address[] memory：动态地址数组，存储在临时内存中（view 函数不能返回 storage 数组）。
    }
}
