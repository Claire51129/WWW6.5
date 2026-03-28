// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 简化版 ERC721 接口
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract NFTMarketplace {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    uint256 public nextListingId;

    mapping(uint256 => Listing) public listings;

    event NFTListed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );

    event ListingCancelled(uint256 indexed listingId);
    event NFTSold(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 price
    );

    // 上架 NFT
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        require(price > 0, "Price must be greater than zero");

        IERC721 nft = IERC721(nftContract);

        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");

        require(
            nft.getApproved(tokenId) == address(this) ||
                nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        listings[nextListingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });

        emit NFTListed(
            nextListingId,
            msg.sender,
            nftContract,
            tokenId,
            price
        );

        nextListingId++;
    }

    // 取消上架
    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];

        require(listing.active, "Listing not active");
        require(listing.seller == msg.sender, "Not seller");

        listing.active = false;

        emit ListingCancelled(listingId);
    }

    // 购买 NFT
    function buyNFT(uint256 listingId) external payable {
        Listing storage listing = listings[listingId];

        require(listing.active, "Listing not active");
        require(msg.value >= listing.price, "Insufficient payment");

        IERC721 nft = IERC721(listing.nftContract);

        require(
            nft.ownerOf(listing.tokenId) == listing.seller,
            "Seller no longer owns NFT"
        );

        listing.active = false;

        // 先转 NFT
        nft.transferFrom(listing.seller, msg.sender, listing.tokenId);

        // 再把钱转给卖家
        (bool success, ) = payable(listing.seller).call{value: listing.price}("");
        require(success, "Payment transfer failed");

        // 如果买家多付，退还多余金额
        if (msg.value > listing.price) {
            (bool refundSuccess, ) = payable(msg.sender).call{
                value: msg.value - listing.price
            }("");
            require(refundSuccess, "Refund failed");
        }

        emit NFTSold(listingId, msg.sender, listing.price);
    }

    // 查询某个 listing 是否有效
    function isListingActive(uint256 listingId) external view returns (bool) {
        return listings[listingId].active;
    }

    // 查询完整 listing 信息
    function getListing(uint256 listingId)
        external
        view
        returns (
            address seller,
            address nftContract,
            uint256 tokenId,
            uint256 price,
            bool active
        )
    {
        Listing memory listing = listings[listingId];
        return (
            listing.seller,
            listing.nftContract,
            listing.tokenId,
            listing.price,
            listing.active
        );
    }
}