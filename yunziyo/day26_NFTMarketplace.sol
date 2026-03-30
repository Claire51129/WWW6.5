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

    event Listed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address royaltyReceiver, uint256 royaltyPercent);
    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address seller, address royaltyReceiver, uint256 royaltyAmount, uint256 marketplaceFeeAmount);
    event Unlisted(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event FeeUpdated(uint256 newMarketplaceFee, address newFeeRecipient);

    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Max 10%");
        require(_feeRecipient != address(0), "Zero address");

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external {
        require(price > 0, "Price zero");
        require(royaltyPercent <= 1000, "Max 10% royalty");
        require(!listings[nftAddress][tokenId].isListed, "Listed");

        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Not approved"
        );

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
        require(item.isListed, "Not listed");
        require(msg.value == item.price, "Price mismatch");

        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        // Effect: Delete listing BEFORE interactions
        delete listings[nftAddress][tokenId];

        // Interaction: NFT Transfer
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // Interaction: Payments
        if (feeAmount > 0) {
            (bool s1, ) = payable(feeRecipient).call{value: feeAmount}("");
            require(s1, "Fee failed");
        }

        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            (bool s2, ) = payable(item.royaltyReceiver).call{value: royaltyAmount}("");
            require(s2, "Royalty failed");
        }

        (bool s3, ) = payable(item.seller).call{value: sellerAmount}("");
        require(s3, "Seller pay failed");

        emit Purchase(msg.sender, nftAddress, tokenId, msg.value, item.seller, item.royaltyReceiver, royaltyAmount, feeAmount);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external {
        require(listings[nftAddress][tokenId].seller == msg.sender, "Not seller");
        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    receive() external payable { revert(); }
    fallback() external payable { revert(); }
}
