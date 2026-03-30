// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. 引入必要的接口（为了GitHub编译，我们手动定义）
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 2. 防重入基础合约
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() { _status = _NOT_ENTERED; }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        uint256 royaltyPercent;
    }

    uint256 public marketplaceFeePercent = 2; // 2% 平台费
    address public feeRecipient; // 平台费接收地址
    mapping(bytes32 => Listing) public listings;

    event Listed(bytes32 indexed listingId, address indexed seller, uint256 price);
    event Purchase(bytes32 indexed listingId, address indexed buyer, uint256 price);

    constructor(address _feeRecipient) {
        feeRecipient = _feeRecipient;
    }

    // 挂单：卖家调用
    function listNFT(address _nftContract, uint256 _tokenId, uint256 _price, uint256 _royaltyPercent) external {
        require(_price > 0, "Price must be > 0");
        require(_royaltyPercent <= 10, "Royalty max 10%");

        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(nft.isApprovedForAll(msg.sender, address(this)) || nft.getApproved(_tokenId) == address(this), "Not approved");

        bytes32 listingId = keccak256(abi.encodePacked(_nftContract, _tokenId, msg.sender));
        listings[listingId] = Listing(msg.sender, _nftContract, _tokenId, _price, _royaltyPercent);

        emit Listed(listingId, msg.sender, _price);
    }

    // 购买：买家调用 (核心逻辑：CEI模式)
    function buyNFT(bytes32 listingId) external payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(listing.price > 0, "Not listed");
        require(msg.value == listing.price, "Incorrect ETH sent");

        // 1. Effects: 先删除挂单，防止重入
        delete listings[listingId];

        // 2. 计算费用
        uint256 mktFee = (listing.price * marketplaceFeePercent) / 100;
        uint256 royaltyFee = (listing.price * listing.royaltyPercent) / 100;
        uint256 sellerProceeds = listing.price - mktFee - royaltyFee;

        // 3. Interactions: 转账与转移NFT
        IERC721(listing.nftContract).transferFrom(listing.seller, msg.sender, listing.tokenId);
        
        payable(feeRecipient).transfer(mktFee); // 平台费
        payable(listing.seller).transfer(sellerProceeds + royaltyFee); // 卖家收入(含版税)

        emit Purchase(listingId, msg.sender, listing.price);
    }
}
