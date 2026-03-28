// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//这个合约是一个**完全链上的NFT市场**，用纯Solidity编写。它让人们：
//- **列出他们的NFT出售**，设置价格甚至自定义版税
//- 通过直接向合约发送ETH来**购买NFT**
//- **自动分割销售**在卖家、创作者（版税）和平台（市场费用）之间
//- 随时**取消列表**
//- 作为市场所有者**更新费用设**
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 建议引入 Ownable 替代手写的 onlyOwner，更安全标准
// import "@openzeppelin/contracts/access/Ownable.sol"; 

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

    // --- 事件保持不变 ---
    event Listed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address royaltyReceiver, uint256 royaltyPercent);
    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price, address seller, address royaltyReceiver, uint256 royaltyAmount, uint256 marketplaceFeeAmount);
    event Unlisted(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event FeeUpdated(uint256 newMarketplaceFee, address newFeeRecipient);

    // --- 错误定义 (Gas 优化) ---
    error MarketplaceFeeTooHigh();
    error InvalidAddress();
    error OnlyOwner();
    error PriceMustBeAboveZero();
    error MaxRoyaltyExceeded();
    error AlreadyListed();
    error NotOwner();
    error MarketplaceNotApproved();
    error NotListed();
    error IncorrectEthSent();
    error FeesExceedLimit();
    error NotTheSeller();
    error DirectEthNotAccepted();
    error TransferFailed();

    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        if (_marketplaceFeePercent > 1000) revert MarketplaceFeeTooHigh();
        if (_feeRecipient == address(0)) revert InvalidAddress();

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    // --- 内部安全转账函数 ---
    function _safeTransferETH(address recipient, uint256 amount) internal {
        if (amount == 0) return; // 避免空转账节省 Gas
        
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        if (_newFee > 1000) revert MarketplaceFeeTooHigh();
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        if (_newRecipient == address(0)) revert InvalidAddress();
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
        if (price == 0) revert PriceMustBeAboveZero();
        if (royaltyPercent > 1000) revert MaxRoyaltyExceeded();
        if (listings[nftAddress][tokenId].isListed) revert AlreadyListed();

        IERC721 nft = IERC721(nftAddress);
        if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();
        if (
            nft.getApproved(tokenId) != address(this) && 
            !nft.isApprovedForAll(msg.sender, address(this))
        ) revert MarketplaceNotApproved();

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
        
        // 1. 检查
        if (!item.isListed) revert NotListed();
        if (msg.value != item.price) revert IncorrectEthSent();
        if (item.royaltyPercent + marketplaceFeePercent > 10000) revert FeesExceedLimit();

        // 2. 计算金额
        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        // 3. 效应 (更新状态 BEFORE 交互)
        // 这一步至关重要：先删除列表，防止重入攻击
        delete listings[nftAddress][tokenId];

        // 转移 NFT
        // 注意：safeTransferFrom 可能会调用接收者的合约代码，所以必须在转账 ETH 之前或之后小心处理
        // 但通常 NFT 转移比 ETH 转移安全，且必须在删除列表后进行
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 4. 交互 (发送 ETH)
        // 使用优化后的 _safeTransferETH
        
        // 市场费用
        if (feeAmount > 0) {
            _safeTransferETH(feeRecipient, feeAmount);
        }

        // 创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            _safeTransferETH(item.royaltyReceiver, royaltyAmount);
        }

        // 卖家支付
        _safeTransferETH(item.seller, sellerAmount);

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

    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        if (!item.isListed) revert NotListed();
        if (item.seller != msg.sender) revert NotTheSeller();

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    receive() external payable {
        revert DirectEthNotAccepted();
    }

    fallback() external payable {
        revert DirectEthNotAccepted();
    }
}

