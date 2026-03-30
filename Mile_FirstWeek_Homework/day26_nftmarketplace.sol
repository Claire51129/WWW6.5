// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 修正后的导入路径 (OpenZeppelin 5.0+)
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title NFT Marketplace
 * @dev 完整的链上NFT市场 - 挂单、购买、版税与手续费分配
 * 文件名: day26_nft_marketplace.sol
 */
contract day26_nft_marketplace is ReentrancyGuard, Ownable {
    // --- 状态变量 ---
    uint256 public marketplaceFeePercent; // 平台手续费率 (例如 2 代表 2%)
    address public feeRecipient;          // 平台费接收地址

    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        uint256 royaltyPercent; // 创作者版税比例 (例如 10 代表 10%)
    }

    // 挂单映射: listingId -> Listing
    mapping(bytes32 => Listing) public listings;

    // --- 事件 ---
    event Listed(bytes32 indexed listingId, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price, uint256 royaltyPercent);
    event Purchase(bytes32 indexed listingId, address indexed buyer, address indexed seller, uint256 price);
    event Unlisted(bytes32 indexed listingId);
    event FeeUpdated(uint256 newFeePercent);

    /**
     * @param _feePercent 初始平台手续费率
     * @param _feeRecipient 平台费接收地址
     */
    constructor(uint256 _feePercent, address _feeRecipient) Ownable(msg.sender) {
        require(_feePercent <= 100, "Fee too high");
        require(_feeRecipient != address(0), "Invalid recipient");
        marketplaceFeePercent = _feePercent;
        feeRecipient = _feeRecipient;
    }

    // --- 核心功能 ---

    /**
     * @dev 挂单 NFT
     */
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 royaltyPercent
    ) external {
        require(price > 0, "Price must be > 0");
        require(royaltyPercent <= 100, "Royalty too high");

        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
        require(
            nft.getApproved(tokenId) == address(this) || 
            nft.isApprovedForAll(msg.sender, address(this)),
            "Not approved to market"
        );

        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, msg.sender));

        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            royaltyPercent: royaltyPercent
        });

        emit Listed(listingId, msg.sender, nftContract, tokenId, price, royaltyPercent);
    }

    /**
     * @dev 购买 NFT
     * 采用 CEI (Checks-Effects-Interactions) 模式防范重入
     */
    function buyNFT(bytes32 listingId) external payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(listing.price > 0, "Not listed");
        require(msg.value == listing.price, "Incorrect price paid");

        // 1. Effects: 先移除挂单状态
        delete listings[listingId];

        // 2. 计算费用分配
        uint256 marketplaceFee = (listing.price * marketplaceFeePercent) / 100;
        uint256 royaltyFee = (listing.price * listing.royaltyPercent) / 100;
        uint256 sellerProceeds = listing.price - marketplaceFee - royaltyFee;

        // 3. Interactions: 转移 NFT
        IERC721(listing.nftContract).transferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        // 4. Interactions: 分配 ETH
        if (marketplaceFee > 0) {
            (bool feeSuccess, ) = payable(feeRecipient).call{value: marketplaceFee}("");
            require(feeSuccess, "Marketplace fee transfer failed");
        }
        
        if (royaltyFee > 0) {
            (bool royaltySuccess, ) = payable(listing.seller).call{value: royaltyFee}("");
            require(royaltySuccess, "Royalty transfer failed");
        }

        (bool sellerSuccess, ) = payable(listing.seller).call{value: sellerProceeds}("");
        require(sellerSuccess, "Seller proceeds transfer failed");

        emit Purchase(listingId, msg.sender, listing.seller, listing.price);
    }

    /**
     * @dev 取消挂单
     */
    function cancelListing(bytes32 listingId) external {
        Listing memory listing = listings[listingId];
        require(listing.seller == msg.sender, "Only seller can cancel");
        
        delete listings[listingId];
        emit Unlisted(listingId);
    }

    // --- 管理函数 ---

    function setMarketplaceFeePercent(uint256 _newFeePercent) external onlyOwner {
        require(_newFeePercent <= 100, "Fee too high");
        marketplaceFeePercent = _newFeePercent;
        emit FeeUpdated(_newFeePercent);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid address");
        feeRecipient = _newRecipient;
    }

    receive() external payable {
        revert("Direct payments not accepted");
    }
}