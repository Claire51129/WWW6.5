// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title NFTMarketplace
 * @dev 这是一个去中心化的 NFT 交易市场合约，支持固定价格挂单、版税支付以及平台分成。
 * 合约使用了 OpenZeppelin 的 ReentrancyGuard 来防止重入攻击。
 */
contract NFTMarketplace is ReentrancyGuard {
    address public owner;
    uint256 public marketplaceFeePercent; // 平台手续费（基点单位，100 = 1%）
    address public feeRecipient;           // 手续费接收地址

    /**
     * @dev 挂单信息结构体
     * @param seller 卖家地址
     * @param nftAddress NFT 合约地址
     * @param tokenId NFT 唯一编号
     * @param price 出售价格（以 wei 为单位）
     * @param royaltyReceiver 版税接收者
     * @param royaltyPercent 版税比例（基点单位）
     * @param isListed 是否处于挂单状态
     */
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        address royaltyReceiver;
        uint256 royaltyPercent;
        bool isListed;
    }

    // 存储所有活跃挂单：nftAddress => tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 事件定义
    event Listed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address royaltyReceiver, uint256 royaltyPercent);
    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address seller, address royaltyReceiver, uint256 royaltyAmount, uint256 marketplaceFeeAmount);
    event Unlisted(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event FeeUpdated(uint256 newMarketplaceFee, address newFeeRecipient);

    /**
     * @dev 初始化合约，设置初始平台费率和接收地址
     */
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev 限制仅合约所有者可执行
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /**
     * @notice 更新平台手续费比例
     * @param _newFee 新的费率（基点）
     */
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    /**
     * @notice 更新手续费接收地址
     * @param _newRecipient 新地址
     */
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    /**
     * @notice 将 NFT 挂单出售
     * @dev 卖家必须先通过 NFT 合约授权当前市场合约
     */
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external {
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");
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

        emit Listed(msg.sender, nftAddress, tokenId, price, royaltyReceiver, royaltyPercent);
    }

    /**
     * @notice 购买指定的 NFT
     * @dev 包含资金分配逻辑：平台费、版税及卖家货款
     */
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(msg.value == item.price, "Incorrect ETH sent");
        require(
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Combined fees exceed 100%"
        );

        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        // 转移平台手续费
        if (feeAmount > 0) {
            payable(feeRecipient).transfer(feeAmount);
        }

        // 转移创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            payable(item.royaltyReceiver).transfer(royaltyAmount);
        }

        // 转移卖家所得货款
        payable(item.seller).transfer(sellerAmount);

        // 资产所有权转移
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 清除挂单状态
        delete listings[nftAddress][tokenId];

        emit Purchase(msg.sender, nftAddress, tokenId, msg.value, item.seller, item.royaltyReceiver, royaltyAmount, feeAmount);
    }

    /**
     * @notice 取消 NFT 挂单
     */
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    /**
     * @notice 获取挂单详情
     */
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    receive() external payable {
        revert("Direct ETH not accepted");
    }

    fallback() external payable {
        revert("Unknown function");
    }
}