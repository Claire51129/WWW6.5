// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 ERC721 接口（NFT 标准）
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// 防重入攻击保护,防止恶意合同，确保函数的执行期间不能被再次调用
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title NFT 市场合约（支持版税和平台手续费）
contract NFTMarketplace is ReentrancyGuard {

    // ===== 基本信息 =====
    address public owner;                     // 合约拥有者
    uint256 public marketplaceFeePercent;    // 平台手续费（以基点为单位，100 = 1%）
    address public feeRecipient;             // 平台手续费接收者

    // ===== NFT 列表结构体 =====
    struct Listing {
        address seller;            // 卖家地址
        address nftAddress;        // NFT 合约地址
        uint256 tokenId;           // NFT Token ID
        uint256 price;             // 售价（ETH）
        address royaltyReceiver;   // 创作者地址（版税接收者）
        uint256 royaltyPercent;    // 版税比例（以基点为单位，10000 = 100%）
        bool isListed;             // 是否已上架
    }

    // NFT 合约地址 → TokenID → Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    // ===== 事件 =====
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

    // ===== 构造函数 =====
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)"); // 最大 10% 平台费
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");           // 平台费接收者不能是零地址
        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    // ===== 权限修饰器 =====
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // ===== 设置平台手续费 =====
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    // ===== 设置手续费接收者 =====
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    // ===== 上架 NFT =====
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external {
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty allowed"); // 最大 10% 版税
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner"); // 必须是 NFT 拥有者
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved" // 必须授权市场合约转 NFT
        );

        // 创建列表
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

    // ===== 购买 NFT =====
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");             // 必须已上架
        require(msg.value == item.price, "Incorrect ETH sent"); // 必须支付正确价格
        require(item.royaltyPercent + marketplaceFeePercent <= 10000, "Combined fees exceed 100%"); // 总费不能超 100%

        // 计算平台费和创作者版税
        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        // 转平台费
        if (feeAmount > 0) {
            (bool feeSent, ) = feeRecipient.call{value: feeAmount}("");
            require(feeSent, "Transfer failed");
        }

        // 转创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            (bool royaltySent, ) = item.royaltyReceiver.call{value: royaltyAmount}("");
            require(royaltySent, "Transfer failed");
        }

        // 转卖家金额
        (bool sellerSent, ) = item.seller.call{value: sellerAmount}("");
        require(sellerSent, "Transfer failed");

        // NFT 转给买家
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 删除上架记录
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

    // ===== 取消上架 =====
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    // ===== 查询 NFT 上架信息 =====
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    // ===== 禁止直接发送 ETH =====
    ///    为什么要禁止？如果用户直接给合约发 ETH（不通过 buyNFT），会出现两种问题：
    ///ETH 会被困在合约里，无法自动分配给卖家、平台和创作者
    ///可能绕过逻辑，造成状态不一致（比如 NFT 没转走，ETH 已到账）
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    fallback() external payable {
        revert("Unknown function");
    }
}