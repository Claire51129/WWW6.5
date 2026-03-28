// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 的 ERC-721 接口和重入锁
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// NFT 交易市场合约
contract NFTMarketplace is ReentrancyGuard {

    address public owner;                    // 市场管理员
    uint256 public marketplaceFeePercent;     // 平台手续费，单位基点（100 基点 = 1%）
    address public feeRecipient;             // 手续费收款地址

    // 上架信息结构体 - 记录每个挂售的 NFT 的详情
    struct Listing {
        address seller;           // 卖家地址
        address nftAddress;       // NFT 合约地址（哪个系列的 NFT）
        uint256 tokenId;          // NFT 的编号
        uint256 price;            // 售价（wei）
        address royaltyReceiver;  // 版税接收者（通常是 NFT 的原始创作者）
        uint256 royaltyPercent;   // 版税比例，基点（比如 500 = 5%）
        bool isListed;            // 是否在售
    }

    // 嵌套 mapping：NFT 合约地址 => (tokenId => 上架信息)
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 事件
    event Listed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId,
        uint256 price, address royaltyReceiver, uint256 royaltyPercent);       // NFT 上架
    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId,
        uint256 price, address seller, address royaltyReceiver,
        uint256 royaltyAmount, uint256 marketplaceFeeAmount);                   // NFT 成交
    event Unlisted(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);  // NFT 下架
    event FeeUpdated(uint256 newMarketplaceFee, address newFeeRecipient);       // 费率更新

    // 构造函数 - 设置平台手续费和收款地址
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");  // 最高 10%
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // 修改平台手续费率 - 仅管理员
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");  // 上限 10%
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    // 修改手续费收款地址 - 仅管理员
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    // 上架 NFT - 卖家把 NFT 挂到市场上出售
    function listNFT(
        address nftAddress,         // NFT 合约地址
        uint256 tokenId,            // 要卖的 NFT 编号
        uint256 price,              // 定价（wei）
        address royaltyReceiver,    // 版税收款人（创作者）
        uint256 royaltyPercent      // 版税比例（基点）
    ) external {
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");       // 版税上限 10%
        require(!listings[nftAddress][tokenId].isListed, "Already listed"); // 不能重复上架

        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");  // 必须是 NFT 的所有者

        // 检查市场合约是否被授权转移这个 NFT
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        // 创建上架记录
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

    // 购买 NFT - 买家付 ETH，合约自动分账并转移 NFT
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");                    // NFT 必须在售
        require(msg.value == item.price, "Incorrect ETH sent");  // 必须精确支付标价

        // 安全检查：平台费 + 版税不能超过 100%（否则卖家一分钱拿不到）
        require(
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Combined fees exceed 100%"
        );

        // 计算三方分账
        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;     // 平台手续费
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;   // 创作者版税
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;        // 卖家实际收入

        // 第一笔：平台手续费 → 平台收款地址
        if (feeAmount > 0) {
        (bool success1, ) = payable(feeRecipient).call{value: feeAmount}("");
        require(success1, "Fee transfer failed");
        }

        // 第二笔：创作者版税 → 创作者地址
        // 这就是 NFT 的核心价值之一：创作者在每次二手交易中都能自动获得分成
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
        (bool success2, ) = payable(item.royaltyReceiver).call{value: royaltyAmount}("");
        require(success2, "Royalty transfer failed");
        }

        // 第三笔：剩余金额 → 卖家
        (bool success3, ) = payable(item.seller).call{value: sellerAmount}("");
        require(success3, "Seller transfer failed");

        // 将 NFT 从卖家转移给买家
        // safeTransferFrom：安全转移，如果买家是合约会检查是否支持接收 NFT
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 删除上架记录（已售出）
        delete listings[nftAddress][tokenId];

        emit Purchase(msg.sender, nftAddress, tokenId, msg.value,
            item.seller, item.royaltyReceiver, royaltyAmount, feeAmount);
    }

    // 取消上架 - 卖家下架自己的 NFT
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");              // 必须在售
        require(item.seller == msg.sender, "Not the seller"); // 只有卖家能下架

        delete listings[nftAddress][tokenId];  // 删除上架记录
        emit Unlisted(msg.sender, nftAddress, tokenId);
        // NFT 本来就在卖家手里，下架不需要转移任何东西
    }

    // 查询上架信息
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    // 禁止直接转 ETH 到合约（必须通过 buyNFT 函数购买）
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    // 禁止调用不存在的函数
    fallback() external payable {
        revert("Unknown function");
    }
}