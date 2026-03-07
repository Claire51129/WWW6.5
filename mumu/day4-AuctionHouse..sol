// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AuctionHouse
 * @author mumu
 * @notice This contract is a simple auction that allows users to bid on a item
 * @dev This contract is a simple auction that allows users to bid on a item
 */
contract AuctionHouse{
    address public owner; // 举办人
    string public itemName; // 拍卖物品的名称
    uint256 public endTime; // 拍卖结束的时间, 秒级时间戳
    mapping(address => uint256) public bids; // 投标人及其投标金额
    address[] public bidders; // 投标人列表
    uint256 private highestBid; // 最高投标金额
    address private highestBidder; // 最高投标人
    bool public ended; // 拍卖是否结束

    // 构造函数，初始化拍卖物品的名称和拍卖结束的时间
    constructor(string memory _itemName, uint256 _endTime) {
        owner = msg.sender; 
        itemName = _itemName;
        endTime = _endTime;
    }

    // 投标函数，投标人可以投标，如果投标金额大于最高投标金额，则成为最高投标人
    function bid(uint _amount) external {
        require(_amount > 0, "Bid amount must be greater than 0"); // 入参检查
        require(block.timestamp < endTime, "Auction already ended");
        require(_amount > highestBid, "There already is a higher bid");

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = _amount;
        
        if (_amount > highestBid) {
            highestBid = _amount;
            highestBidder = msg.sender;
        }
    }

    // 终止拍卖函数，只有举办人可以终止拍卖
    function endAuction() external {
        require(msg.sender == owner, "Only the owner can end the auction");
        require(!ended, "Auction already ended");
        ended = true;
    }

    // 获取投标人列表
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    // 获取最高投标金额
    function getHighestBid() external view returns (uint256) {
        return highestBid;
    }

    // 获取最高投标人
    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }
    
    // getWinner
    function getWinner() external view returns (address, uint256) {
        return (highestBidder, highestBid);
    }
}

/**
external function:
    - external function is a function that can be called by other contracts

internal function:
    - internal function is a function that can be called by other functions in the same contract

public function:
    - public function is a function that can be called by other contracts and external functions

private function:
    - private function is a function that can be called only by other functions in the same contract
 */