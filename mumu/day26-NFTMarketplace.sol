// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    address public owner;
    // 平台手续费
    uint256 public marketplaceFeePercent; // 以基点为单位 (100 = 1%)
    // 接受市场份额的钱包？也就是NFT交易时的钱包
    address public feeRecipient;

    struct Listing {
        address seller; // 卖家
        address nftAddress;  // NFT合约的地址
        uint256 tokenId;  // NFTid
        uint256 price;  // 定价
        address royaltyReceiver;  // 创作者接受版税的地址
        uint256 royaltyPercent; // 以基点为单位，版税百分比
        bool isListed;  // 是否列出
    }

    // map[nftaddress][tokenid] -》 商品信息
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 商品展出事件
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    );

    // 购买事件
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

    // 类似下架事件
    event Unlisted(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    // 手续费变更事件
    event FeeUpdated(
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );

    // 部署市场合约时，初始化市场手续费、接受NFT的地址
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
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
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        // 或者NFT信息，检查owner
        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            // NFT需要提前授权给市场合约交易权限
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

    // 购买NFT
    // external：由用户从合约外部调用
    // nonReentrant：使用reentrancyGuard 防止重入攻击
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

        // 市场费用
        if (feeAmount > 0) {
            (bool success, ) = payable(feeRecipient).call{value: feeAmount}("");
            require(success, "Fee transfer failed");
        }

        // 创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            (bool success, ) = payable(item.royaltyReceiver).call{value: royaltyAmount}("");
            require(success, "Royalty transfer failed");
        }

        // 卖家支付
        (bool success, ) = payable(item.seller).call{value: sellerAmount}("");
        require(success, "Seller transfer failed");

        // 将NFT转移给买家
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 删除列表
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

    // 取消交易
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    // 拒绝直接向合约发送ETH
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    // 拒绝位置函数的调用
    fallback() external payable {
        revert("Unknown function");
    }
}

/**
key word: NFT交易、费用分配、ReentrancyGuard、 IERC721接口

- 挂单系统：支持自定义价格和版税挂单NFT，也就是如果别人觉得价格合适，可以直接进行交易？

- 三层费用分配：
    平台手续费、创作者版税、卖家收益

- 其他：安全机制、标准集成

- 几个角色：买家、卖家、创作者、平台(市场合约)
卖家：卖家收入 = 总价 - (总价 × 平台费率) - (总价 × 版税费率)
 */