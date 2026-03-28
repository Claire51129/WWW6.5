//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
  address public owner;
  uint256 public marketplaceFeePercent; //in basis points (e.g., 100 for 1%)
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
    uint256 marketplaceFee
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

  constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
    require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (>10%)");
    require(_feeRecipient != address(0), "Invalid fee recipient");

    owner = msg.sender;
    marketplaceFeePercent = _marketplaceFeePercent;
    feeRecipient = _feeRecipient;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }
  
  function setMarketplaceFeePercent(uint256 _newmarketplaceFeePercent) external onlyOwner {
    require(_newmarketplaceFeePercent <= 1000, "Marketplace fee too high (>10%)");
    marketplaceFeePercent = _newmarketplaceFeePercent;
    emit FeeUpdated(_newmarketplaceFeePercent, feeRecipient);
  }

  function setFeeRecipient(address _newRecipient) external onlyOwner {
    require(_newRecipient != address(0), "Invalid fee recipient");
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
    require(price > 0, "Price must be greater than zero");
    require(royaltyPercent <= 1000, "Royalty percent too high (>10%)");
    require(!listings[nftAddress][tokenId].isListed, "NFT already listed");

    IERC721 nft = IERC721(nftAddress);
    require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");
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

  function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
    Listing memory item = listings[nftAddress][tokenId];
    require(item.isListed, "NFT not listed for sale");
    require(msg.value == item.price, "Incorrect payment amount");
    require(item.royaltyPercent + marketplaceFeePercent <= 1000, "Total fees exceed 10%");

    uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
    uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
    uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

    //Marketplace fee transfer
    if (feeAmount > 0) {
      payable(feeRecipient).transfer(feeAmount);
    }

    //Creator royalty transfer
    if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
      payable(item.royaltyReceiver).transfer(royaltyAmount);
    }

    //Seller payout
    payable(item.seller).transfer(sellerAmount);

    //transfer NFT to buyer
    IERC721(nftAddress).safeTransferFrom(item.seller, msg.sender, tokenId);

    //remove listing
    delete listings[nftAddress][tokenId];

    emit Purchase(
      msg.sender,
      nftAddress,
      tokenId,
      msg.value,
      item.seller,
      item.royaltyReceiver,
      royaltyAmount,
      feeAmount
    );
  }

  function cancelListing(address nftAddress, uint256 tokenId) external {
    Listing memory item = listings[nftAddress][tokenId];
    require(item.isListed, "NFT not listed");
    require(item.seller == msg.sender, "Only seller can cancel listing");

    delete listings[nftAddress][tokenId];

    emit Unlisted(msg.sender, nftAddress, tokenId);
  }

  function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
    return listings[nftAddress][tokenId];
  }

  receive() external payable {
    revert("Direct payments not allowed");
  }

  fallback() external payable {
    revert("Direct payments not allowed");
  }
}