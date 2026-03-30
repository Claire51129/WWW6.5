// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 ERC721 接口
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// 引入防重入攻击
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title NFTMarketplace - 支持版税 + 平台手续费的NFT交易市场
contract NFTMarketplace is ReentrancyGuard {

    // ===================== 状态变量 =====================

    address public owner; // 合约管理员

    uint256 public marketplaceFeePercent; // 平台手续费（基点：100 = 1%）

    address public feeRecipient; // 手续费接收地址

    bool public paused; // 是否暂停交易


    // ===================== 数据结构 =====================

    struct Listing {
        address seller;          // 卖家
        address nftAddress;      // NFT 合约地址
        uint256 tokenId;         // NFT ID
        uint256 price;           // 售价
        address royaltyReceiver; // 版税接收者
        uint256 royaltyPercent;  // 版税比例（基点）
        bool isListed;           // 是否上架
    }

    // nft地址 => tokenId => listing
    mapping(address => mapping(uint256 => Listing)) public listings;


    // ===================== 事件 =====================

    event Listed(address seller, address nftAddress, uint256 tokenId, uint256 price);

    event Purchase(address buyer, address nftAddress, uint256 tokenId, uint256 price);

    event Unlisted(address seller, address nftAddress, uint256 tokenId);

    event FeeUpdated(uint256 newFee, address newRecipient);

    event Paused(bool status);


    // ===================== 构造函数 =====================

    constructor(uint256 _feePercent, address _feeRecipient) {
        require(_feePercent <= 1000, "Fee too high"); // 最大10%
        require(_feeRecipient != address(0), "Invalid address");

        owner = msg.sender;
        marketplaceFeePercent = _feePercent;
        feeRecipient = _feeRecipient;
    }


    // ===================== 修饰器 =====================

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Marketplace paused");
        _;
    }


    // ===================== 管理功能 =====================

    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit Paused(_paused);
    }


    // ===================== 核心功能 =====================

    /// 上架NFT
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external notPaused {

        require(price > 0, "Price must > 0");
        require(royaltyPercent <= 1000, "Max 10%");
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        IERC721 nft = IERC721(nftAddress);

        // 必须是拥有者
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");

        // 必须授权市场
        require(
            nft.getApproved(tokenId) == address(this) ||
            nft.isApprovedForAll(msg.sender, address(this)),
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

        emit Listed(msg.sender, nftAddress, tokenId, price);
    }


    /// 购买NFT（核心安全逻辑）
    function buyNFT(address nftAddress, uint256 tokenId)
        external
        payable
        nonReentrant
        notPaused
    {
        Listing storage item = listings[nftAddress][tokenId];

        require(item.isListed, "Not listed");
        require(msg.value == item.price, "Wrong price");

        // 再次确认 NFT 仍然属于卖家（防止转走）
        require(
            IERC721(nftAddress).ownerOf(tokenId) == item.seller,
            "Seller no longer owns NFT"
        );

        require(
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Fee overflow"
        );

        // ===== 计算金额 =====
        uint256 fee = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royalty = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - fee - royalty;

        // ===== 先删除状态（防重入关键）=====
        delete listings[nftAddress][tokenId];

        // ===== 转 NFT =====
        IERC721(nftAddress).safeTransferFrom(item.seller, msg.sender, tokenId);

        // ===== 转钱 =====

        if (fee > 0) {
            payable(feeRecipient).transfer(fee);
        }

        if (royalty > 0 && item.royaltyReceiver != address(0)) {
            payable(item.royaltyReceiver).transfer(royalty);
        }

        payable(item.seller).transfer(sellerAmount);

        emit Purchase(msg.sender, nftAddress, tokenId, msg.value);
    }


    /// 取消上架
    function cancelListing(address nftAddress, uint256 tokenId) external {

        Listing storage item = listings[nftAddress][tokenId];

        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not seller");

        delete listings[nftAddress][tokenId];

        emit Unlisted(msg.sender, nftAddress, tokenId);
    }


    /// 查询
    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return listings[nftAddress][tokenId];
    }


    // ===================== 安全 =====================

    receive() external payable {
        revert("No direct ETH");
    }

    fallback() external payable {
        revert("Invalid call");
    }
}