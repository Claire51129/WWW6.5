// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 合约
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title NFT 市场合约
/// @title NFT Marketplace
/// @dev 一个简单的 NFT 交易市场合约，支持挂单、购买、版税和市场费用
/// @dev 继承 ReentrancyGuard 防止重入攻击
contract NFTMarketplace is ReentrancyGuard {
    
    // ==================== 状态变量 ====================
    
    /// @notice 合约所有者地址
    /// @dev 拥有管理权限，可以修改市场费用等
    address public owner;
    
    /// @notice 市场手续费比例（以基点为单位）
    /// @dev 100 = 1%，10000 = 100%
    /// @dev 例如：250 表示 2.5% 的手续费
    uint256 public marketplaceFeePercent;
    
    /// @notice 市场手续费接收地址
    /// @dev 平台收取的手续费会发送到这个地址
    address public feeRecipient;

    /// @notice NFT 挂单信息结构体
    /// @dev 存储每个 NFT 的挂单详情
    struct Listing {
        address seller;           // 卖家地址
        address nftAddress;       // NFT 合约地址
        uint256 tokenId;          // NFT 代币 ID
        uint256 price;            // 售价（以 wei 为单位）
        address royaltyReceiver;  // 版税接收地址（通常是创作者）
        uint256 royaltyPercent;   // 版税比例（基点）
        bool isListed;            // 是否正在挂单中
    }

    /// @notice 挂单映射表
    /// @dev NFT合约地址 => TokenID => 挂单信息
    /// @dev 使用双重映射来定位每个 NFT 的挂单
    mapping(address => mapping(uint256 => Listing)) public listings;

    // ==================== 事件 ====================
    
    /// @notice NFT 挂单事件
    /// @param seller 卖家地址
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @param price 售价
    /// @param royaltyReceiver 版税接收地址
    /// @param royaltyPercent 版税比例
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    );

    /// @notice NFT 购买事件
    /// @param buyer 买家地址
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @param price 成交价格
    /// @param seller 卖家地址
    /// @param royaltyReceiver 版税接收地址
    /// @param royaltyAmount 版税金额
    /// @param marketplaceFeeAmount 市场手续费金额
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

    /// @notice 取消挂单事件
    /// @param seller 卖家地址
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    event Unlisted(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    /// @notice 费用更新事件
    /// @param newMarketplaceFee 新的市场手续费比例
    /// @param newFeeRecipient 新的手续费接收地址
    event FeeUpdated(
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );

    // ==================== 构造函数 ====================
    
    /// @notice 创建 NFT 市场合约
    /// @param _marketplaceFeePercent 市场手续费比例（基点）
    /// @param _feeRecipient 手续费接收地址
    /// @dev 初始化合约时设置手续费参数
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        // 检查手续费不超过 10%（1000 基点）
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");
        // 检查手续费接收地址不为零地址
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");

        owner = msg.sender;  // 设置合约所有者为部署者
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    // ==================== 修饰符 ====================
    
    /// @notice 仅所有者修饰符
    /// @dev 限制只有合约所有者可以调用某些函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // ==================== 管理函数 ====================
    
    /// @notice 设置市场手续费比例
    /// @param _newFee 新的手续费比例（基点）
    /// @dev 只有合约所有者可以调用
    /// @dev 手续费不能超过 10%
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    /// @notice 设置手续费接收地址
    /// @param _newRecipient 新的接收地址
    /// @dev 只有合约所有者可以调用
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    // ==================== 核心功能 ====================
    
    /// @notice 挂单出售 NFT
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @param price 售价（wei）
    /// @param royaltyReceiver 版税接收地址
    /// @param royaltyPercent 版税比例（基点）
    /// @dev 卖家需要提前授权市场合约转移其 NFT
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external {
        // 检查价格大于 0
        require(price > 0, "Price must be above zero");
        // 检查版税不超过 10%
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");
        // 检查该 NFT 尚未挂单
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        // 获取 NFT 合约接口
        IERC721 nft = IERC721(nftAddress);
        // 检查调用者是 NFT 的所有者
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        // 检查市场合约是否被授权转移该 NFT
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        // 创建挂单信息
        listings[nftAddress][tokenId] = Listing({
            seller: msg.sender,
            nftAddress: nftAddress,
            tokenId: tokenId,
            price: price,
            royaltyReceiver: royaltyReceiver,
            royaltyPercent: royaltyPercent,
            isListed: true
        });

        // 触发挂单事件
        emit Listed(msg.sender, nftAddress, tokenId, price, royaltyReceiver, royaltyPercent);
    }

    /// @notice 购买 NFT
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @dev 买家需要发送正确的 ETH 金额
    /// @dev 使用 nonReentrant 防止重入攻击
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        // 获取挂单信息
        Listing memory item = listings[nftAddress][tokenId];
        // 检查 NFT 正在挂单中
        require(item.isListed, "Not listed");
        // 检查发送的 ETH 金额正确
        require(msg.value == item.price, "Incorrect ETH sent");
        // 检查版税 + 市场费不超过 100%
        require(
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Combined fees exceed 100%"
        );

        // 计算市场手续费
        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
        // 计算版税金额
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
        // 计算卖家实际收到的金额
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

        // ========== 资金分配 ==========
        
        // 1. 支付市场手续费
        // 使用 call 替代已弃用的 transfer
        if (feeAmount > 0) {
            (bool sent, ) = payable(feeRecipient).call{value: feeAmount}("");
            require(sent, "Fee transfer failed");
        }

        // 2. 支付创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            (bool sent, ) = payable(item.royaltyReceiver).call{value: royaltyAmount}("");
            require(sent, "Royalty transfer failed");
        }

        // 3. 支付卖家
        (bool sent, ) = payable(item.seller).call{value: sellerAmount}("");
        require(sent, "Seller transfer failed");

        // ========== NFT 转移 ==========
        
        // 将 NFT 从卖家转移给买家
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 删除挂单记录
        delete listings[nftAddress][tokenId];

        // 触发购买事件
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

    /// @notice 取消挂单
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @dev 只有卖家本人可以取消自己的挂单
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        // 检查 NFT 正在挂单中
        require(item.isListed, "Not listed");
        // 检查调用者是卖家
        require(item.seller == msg.sender, "Not the seller");

        // 删除挂单记录
        delete listings[nftAddress][tokenId];
        // 触发取消挂单事件
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    // ==================== 查询函数 ====================
    
    /// @notice 获取 NFT 的挂单信息
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 代币 ID
    /// @return 挂单信息结构体
    /// @dev view 函数，不消耗 gas
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    // ==================== 回退函数 ====================
    
    /// @notice 接收 ETH 的回退函数
    /// @dev 拒绝直接接收 ETH，必须通过 buyNFT 函数
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    /// @notice 未知函数调用的回退函数
    /// @dev 拒绝所有未知函数调用
    fallback() external payable {
        revert("Unknown function");
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. NFT 市场核心概念:
//    - 挂单（Listing）: 卖家将 NFT 上架出售
//    - 版税（Royalty）: 创作者在每次转售时获得的收益分成
//    - 市场费（Marketplace Fee）: 平台收取的手续费
//    - 重入保护: 使用 OpenZeppelin 的 ReentrancyGuard
//
// 2. 资金分配流程:
//    买家支付 ETH → 市场费（平台）
//                  → 版税（创作者）
//                  → 剩余（卖家）
//    
//    示例（售价 1 ETH）:
//    - 市场费 2.5%: 0.025 ETH
//    - 版税 5%: 0.05 ETH
//    - 卖家收到: 0.925 ETH
//
// 3. 使用流程:
//    卖家挂单:
//    1. 调用 NFT 合约的 approve(marketAddress, tokenId) 授权市场
//    2. 调用 listNFT(nftAddress, tokenId, price, royaltyReceiver, royaltyPercent)
//    
//    买家购买:
//    1. 调用 buyNFT(nftAddress, tokenId)，发送正确的 ETH
//    2. NFT 自动转移给买家，资金自动分配给各方
//    
//    取消挂单:
//    1. 调用 cancelListing(nftAddress, tokenId)
//    2. 只有卖家可以取消
//
// 4. 安全机制:
//    - ReentrancyGuard: 防止重入攻击
//    - 先检查条件，再执行操作
//    - 使用 call{value:...} 替代已弃用的 transfer
//    - 拒绝直接 ETH 转账
//
// 5. 与 OpenSea 的区别:
//    - 这是链上市场，所有逻辑都在合约中
//    - OpenSea 主要使用链下签名 + 链上结算
//    - 支持自定义版税（OpenSea 现在版税是可选的）
//
// 6. 关键知识点:
//    - ERC721 标准: NFT 接口和转移
//    - 重入攻击: 使用 nonReentrant 修饰符防护
//    - 基点计算: 10000 基点 = 100%
//    - call{value:...} 替代 transfer
