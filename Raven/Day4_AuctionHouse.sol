// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
contract AuctionHouse {
	address public owner;
	string public item;
	uint public endTime;
	uint public startPrice;
	address private highestBidder;
	uint private highestBid;
	bool public ended;
	address [] public bidder;
	mapping (address => uint) public bids;

	// Initialize state variables with params
	constructor(string memory _item, uint _biddingTime, uint _startingPrice) {
		owner = msg.sender;
		item = _item;
		endTime = block.timestamp + _biddingTime;
		startPrice = _startingPrice;
	}
	// use msg.value for taking ETH in real case
	function bid(uint _amount) external {
		require(!ended, "Auction has already ended");
		require(_amount > 0, "Bid value has to be positive");
		require(_amount > bids[msg.sender], "Bid cannot decrease");
		// No float and no devision (lose precision)
		require(_amount * 100 > bids[msg.sender] * 105, "new bid must be at least 5% higher");
		require(_amount >= startPrice, "new bid must be at least starting price");
		// Add new address to array in the first time
		if (bids[msg.sender] == 0)
			bidder.push(msg.sender);
		bids[msg.sender] = _amount;
		// Update the highst record
		if (_amount > highestBid)
		{
			highestBid = _amount;
			highestBidder = msg.sender;
		}
	}
	// End the auction only once
	// Avoid wasting gas
	function endAuction() external {
		require(block.timestamp >= endTime, "Auction not at the end");
		require(!ended, "Auction already ended");
		ended = true;
	}
	// Access private variable
	function getBidders() external view returns (address [] memory) {
		return (bidder);
	}
	// Access private variable
	function getWinner() external view returns (address, uint) {
		require(ended, "Auction not ended yet");
		return (highestBidder, highestBid);
	}
}