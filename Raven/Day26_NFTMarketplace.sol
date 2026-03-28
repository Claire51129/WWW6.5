// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
	address public owner;
	uint256 public marketplaceFeePercent;
	address public feeRecipient;
	struct Listing {
		address seller;
		address nftAddress;
		uint256 tokenId;
		uint256 price;
		address royaltyReceiver;
		uint256 royaltyPercent;
		bool isListed;
	}
	mapping(address => mapping(uint256 => Listing)) public listings;
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    );

    event Purchase(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address seller,
        address royaltyReceiver,
        uint256 royaltyAmount,
        uint256 marketplaceFeeAmount
    );

    event Unlisted(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event FeeUpdated(
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );
	constructor(uint256 _marketFeePercent, address _feeRecipient) {
		require(_marketFeePercent <= 1000, "Fee more than 10%");
		require(_feeRecipient != address(0), "Invalid address");
		owner = msg.sender;
		marketplaceFeePercent = _marketFeePercent;
		feeRecipient = _feeRecipient;
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Only owner");
		_;
	}
	// Change market fee
	function setMarketFee(uint256 _newFee) external onlyOwner {
		require(_newFee <= 1000, "Fee more than 10%");
		marketplaceFeePercent = _newFee;
		emit FeeUpdated(_newFee, feeRecipient);
	}
	// Change recipient
	function setFeeRecipient(address _newRecipient) external onlyOwner {
		require(_newRecipient != address(0), "Invalid address");
		feeRecipient = _newRecipient;
		emit FeeUpdated(marketplaceFeePercent, _newRecipient);
	}
	function listNFT(
		address nftAddress,
		uint256 tokenId,
		uint256 price,
		address royaltyReceiver,
		uint256 royaltyPercent
	) external {
		require(price > 0, "Invalid price");
		require(royaltyPercent <= 1000, "Fee more than 10%");
		require(royaltyPercent == 0 || royaltyReceiver != address(0), "Invalid royalty receiver");
		require(!listings[nftAddress][tokenId].isListed, "Already listed");
		IERC721 nft = IERC721(nftAddress);
		// msg.sender should be owner
		require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
		// This contract should be approved
		require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");
		listings[nftAddress][tokenId] = Listing({
			seller: msg.sender,
			nftAddress: nftAddress,
			tokenId: tokenId,
			price: price,
			royaltyReceiver: royaltyReceiver,
            royaltyPercent: royaltyPercent,
            isListed: true
		});
		emit Listed(msg.sender, nftAddress, tokenId, price, royaltyReceiver, royaltyPercent);
	}
	// Protected against reentrancy
	function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
		Listing memory item = listings[nftAddress][tokenId];
		require(item.isListed, "Not listed");
		require(msg.value == item.price, "Incorrect price");
		require(item.royaltyPercent + marketplaceFeePercent <= 10000, "Combined fee more than 100%");
		uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
		uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
		uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;
		// Market fee
		if (feeAmount > 0) {
			(bool feeSuccess, ) = payable(feeRecipient).call{value:feeAmount}("");
			require(feeSuccess, "Fail to transfer");
		}
		// Royalty fee
		if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
			(bool royaltySuccess, ) = payable(item.royaltyReceiver).call{value:royaltyAmount}("");
			require(royaltySuccess, "Fail to transfer");
		}
		// Seller fee
		(bool success, ) = payable(item.seller).call{value:sellerAmount}("");
		require(success, "Fail to transfer");
		// Transfer NFT to buyer
		IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);
		delete listings[nftAddress][tokenId];
		emit Purchase(msg.sender, nftAddress, tokenId, msg.value, item.seller, item.royaltyReceiver, royaltyAmount, feeAmount);
	}
	// Seller cancels listing
	function cancelListing(address nftAddress, uint256 tokenId) external {
		Listing memory item = listings[nftAddress][tokenId];
		require(item.isListed, "Not listed");
		require(item.seller == msg.sender, "Not the seller");
		delete listings[nftAddress][tokenId];
		emit Unlisted(msg.sender, nftAddress, tokenId);
	}
	function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
		return listings[nftAddress][tokenId];
	}
	// Avoid unexpected payment and function
	receive() external payable {
		revert("Direct ETH not accepted");
	}
	fallback() external payable {
		revert("Unknown function");
	}
}
