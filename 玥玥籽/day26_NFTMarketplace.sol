// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

abstract contract ReentrancyGuard {
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

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

    struct Offer {
        address buyer;
        uint256 amount;
        uint256 expiresAt;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => mapping(uint256 => Offer)) public offers; // nft → tokenId → offer

    event Listed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address seller);
    event Unlisted(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event OfferMade(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 amount, uint256 expiresAt);
    event OfferAccepted(address indexed seller, address indexed buyer, address indexed nftAddress, uint256 tokenId, uint256 amount);
    event OfferCancelled(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId);
    event FeeUpdated(uint256 newFee, address newRecipient);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Max 10% fee");
        require(_feeRecipient != address(0), "Invalid fee recipient");
        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external {
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty");
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
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

        emit Listed(msg.sender, nftAddress, tokenId, price);
    }

    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(msg.value == item.price, "Incorrect ETH amount");
        require(item.royaltyPercent + marketplaceFeePercent <= 10000, "Combined fees exceed 100%");

        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        if (feeAmount > 0) payable(feeRecipient).transfer(feeAmount);
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) payable(item.royaltyReceiver).transfer(royaltyAmount);
        payable(item.seller).transfer(sellerAmount);

        IERC721(nftAddress).safeTransferFrom(item.seller, msg.sender, tokenId);
        delete listings[nftAddress][tokenId];

        emit Purchase(msg.sender, nftAddress, tokenId, msg.value, item.seller);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");
        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }


    function makeOffer(address nftAddress, uint256 tokenId, uint256 durationSeconds) external payable {
        require(msg.value > 0, "Offer must be positive");
        require(durationSeconds > 0, "Duration must be positive");
        require(!offers[nftAddress][tokenId].active, "Offer already exists, cancel first");

        offers[nftAddress][tokenId] = Offer({
            buyer: msg.sender,
            amount: msg.value,
            expiresAt: block.timestamp + durationSeconds,
            active: true
        });

        emit OfferMade(msg.sender, nftAddress, tokenId, msg.value, block.timestamp + durationSeconds);
    }

    function acceptOffer(address nftAddress, uint256 tokenId) external nonReentrant {
        Offer memory offer = offers[nftAddress][tokenId];
        require(offer.active, "No active offer");
        require(block.timestamp <= offer.expiresAt, "Offer has expired");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            IERC721(nftAddress).getApproved(tokenId) == address(this) ||
            IERC721(nftAddress).isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        uint256 feeAmount = (offer.amount * marketplaceFeePercent) / 10000;
        uint256 sellerAmount = offer.amount - feeAmount;

        delete offers[nftAddress][tokenId];
        if (listings[nftAddress][tokenId].isListed) delete listings[nftAddress][tokenId];

        if (feeAmount > 0) payable(feeRecipient).transfer(feeAmount);
        payable(msg.sender).transfer(sellerAmount);

        IERC721(nftAddress).safeTransferFrom(msg.sender, offer.buyer, tokenId);

        emit OfferAccepted(msg.sender, offer.buyer, nftAddress, tokenId, offer.amount);
    }

    function cancelOffer(address nftAddress, uint256 tokenId) external nonReentrant {
        Offer memory offer = offers[nftAddress][tokenId];
        require(offer.active, "No active offer");
        require(offer.buyer == msg.sender || block.timestamp > offer.expiresAt, "Not authorized");

        delete offers[nftAddress][tokenId];
        payable(offer.buyer).transfer(offer.amount);

        emit OfferCancelled(offer.buyer, nftAddress, tokenId);
    }

    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Max 10%");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid address");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    function getOffer(address nftAddress, uint256 tokenId) external view returns (Offer memory) {
        return offers[nftAddress][tokenId];
    }

    receive() external payable { revert("Direct ETH not accepted"); }
    fallback() external payable { revert("Unknown function"); }
}
