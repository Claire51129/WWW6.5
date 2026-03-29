// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 ERC721 标准接口
// 用它来和外部 NFT 合约交互，比如查询 owner、检查授权、转移 NFT
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// 引入 OpenZeppelin 的防重入保护
// 这样 buyNFT 在执行过程中不能被恶意重复进入
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title NFTMarketplace
/// @notice 一个支持平台手续费 + 版税分配的 NFT 交易市场
contract NFTMarketplace is ReentrancyGuard {

    // =========================================================
    // 状态变量
    // =========================================================

    // 合约管理员地址
    // 一般是部署合约的人
    address public owner;

    // 平台手续费比例（单位：基点）
    // 100 = 1%
    // 1000 = 10%
    // 10000 = 100%
    uint256 public marketplaceFeePercent;

    // 平台手续费接收地址
    address public feeRecipient;

    // 市场是否暂停
    // true = 暂停，false = 正常
    bool public paused;


    // =========================================================
    // 数据结构
    // =========================================================

    /// @notice 上架信息
    struct Listing {
        address seller;          // 卖家地址
        address nftAddress;      // NFT 合约地址
        uint256 tokenId;         // NFT 的 tokenId
        uint256 price;           // 售价（单位：wei）
        address royaltyReceiver; // 版税接收地址
        uint256 royaltyPercent;  // 版税比例（基点）
        bool isListed;           // 是否处于上架状态
    }

    // 上架记录：
    // NFT合约地址 => tokenId => Listing
    //
    // 比如：
    // listings[0xABC...][1]
    // 表示某个 NFT 合约中 tokenId=1 的上架信息
    mapping(address => mapping(uint256 => Listing)) public listings;


    // =========================================================
    // 事件
    // =========================================================

    // NFT 上架时触发
    event Listed(
        address seller,
        address nftAddress,
        uint256 tokenId,
        uint256 price
    );

    // NFT 成交时触发
    event Purchase(
        address buyer,
        address nftAddress,
        uint256 tokenId,
        uint256 price
    );

    // NFT 取消上架时触发
    event Unlisted(
        address seller,
        address nftAddress,
        uint256 tokenId
    );

    // 平台手续费或手续费接收地址更新时触发
    event FeeUpdated(
        uint256 newFee,
        address newRecipient
    );

    // 市场暂停 / 恢复时触发
    event Paused(bool status);


    // =========================================================
    // 构造函数
    // =========================================================

    /// @param _feePercent 平台手续费（基点）
    /// @param _feeRecipient 平台手续费接收地址
    constructor(uint256 _feePercent, address _feeRecipient) {
        // 限制平台手续费最多 10%
        require(_feePercent <= 1000, "Fee too high");

        // 手续费接收地址不能是零地址
        require(_feeRecipient != address(0), "Invalid address");

        // 部署者自动成为管理员
        owner = msg.sender;

        // 初始化平台手续费
        marketplaceFeePercent = _feePercent;

        // 初始化手续费接收地址
        feeRecipient = _feeRecipient;
    }


    // =========================================================
    // 修饰器
    // =========================================================

    /// @notice 只有管理员可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice 市场未暂停时才允许调用
    modifier notPaused() {
        require(!paused, "Marketplace paused");
        _;
    }


    // =========================================================
    // 管理功能
    // =========================================================

    /// @notice 修改平台手续费比例
    /// @param _newFee 新的平台手续费（基点）
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        // 手续费仍然限制在 10% 以内
        require(_newFee <= 1000, "Too high");

        marketplaceFeePercent = _newFee;

        emit FeeUpdated(_newFee, feeRecipient);
    }

    /// @notice 修改平台手续费接收地址
    /// @param _newRecipient 新接收地址
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid");

        feeRecipient = _newRecipient;

        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    /// @notice 暂停 / 恢复市场
    /// @param _paused true 表示暂停，false 表示恢复
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;

        emit Paused(_paused);
    }


    // =========================================================
    // 核心功能
    // =========================================================

    /// @notice 上架 NFT
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 的 tokenId
    /// @param price 售价（wei）
    /// @param royaltyReceiver 版税接收地址
    /// @param royaltyPercent 版税比例（基点）
    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    ) external notPaused {

        // 价格必须大于 0
        require(price > 0, "Price must > 0");

        // 版税最多 10%
        require(royaltyPercent <= 1000, "Max 10%");

        // 这个 NFT 当前不能已经在上架中
        require(!listings[nftAddress][tokenId].isListed, "Already listed");

        // 把 nftAddress 当成 ERC721 合约接口来使用
        IERC721 nft = IERC721(nftAddress);

        // 检查调用者是不是这个 NFT 的拥有者
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");

        // 检查市场合约是否已被授权
        // 两种授权都可以：
        // 1. 单个 token 授权给本合约
        // 2. 全部 NFT 授权给本合约
        require(
            nft.getApproved(tokenId) == address(this) ||
            nft.isApprovedForAll(msg.sender, address(this)),
            "Not approved"
        );

        // 把上架信息写入链上存储
        listings[nftAddress][tokenId] = Listing({
            seller: msg.sender,
            nftAddress: nftAddress,
            tokenId: tokenId,
            price: price,
            royaltyReceiver: royaltyReceiver,
            royaltyPercent: royaltyPercent,
            isListed: true
        });

        // 触发上架事件
        emit Listed(msg.sender, nftAddress, tokenId, price);
    }


    /// @notice 购买 NFT
    /// @dev 核心逻辑：检查 -> 计算金额 -> 删除状态 -> 转 NFT -> 转钱
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 的 tokenId
    function buyNFT(address nftAddress, uint256 tokenId)
        external
        payable
        nonReentrant
        notPaused
    {
        // 从存储中取出该 NFT 的上架记录
        // storage = 直接引用链上存储，不是复制
        Listing storage item = listings[nftAddress][tokenId];

        // 必须确实已经上架
        require(item.isListed, "Not listed");

        // 买家发来的 ETH 必须刚好等于售价
        require(msg.value == item.price, "Wrong price");

        // 再次确认 NFT 还在卖家手里
        // 防止卖家上架后，把 NFT 在别处转走
        require(
            IERC721(nftAddress).ownerOf(tokenId) == item.seller,
            "Seller no longer owns NFT"
        );

        // 检查总费率不能超过 100%
        // marketplaceFeePercent + royaltyPercent <= 10000
        require(
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Fee overflow"
        );

        // -----------------------------------------------------
        // 1. 计算金额分配
        // -----------------------------------------------------

        // 平台手续费
        uint256 fee = (msg.value * marketplaceFeePercent) / 10000;

        // 版税
        uint256 royalty = (msg.value * item.royaltyPercent) / 10000;

        // 卖家实际收到的金额
        uint256 sellerAmount = msg.value - fee - royalty;

        // -----------------------------------------------------
        // 2. 先删除上架状态（安全关键）
        // -----------------------------------------------------
        //
        // 为什么先删？
        // 因为后面要进行外部调用：
        // - 调 NFT 合约 safeTransferFrom
        // - 给外部地址转 ETH
        //
        // 先删状态，能防止重入时重复购买同一条 listing
        delete listings[nftAddress][tokenId];

        // -----------------------------------------------------
        // 3. 转移 NFT
        // -----------------------------------------------------
        //
        // 从卖家转给买家
        // safeTransferFrom 比 transferFrom 更安全
        IERC721(nftAddress).safeTransferFrom(item.seller, msg.sender, tokenId);

        // -----------------------------------------------------
        // 4. 分钱
        // -----------------------------------------------------

        // 转平台手续费
        if (fee > 0) {
            payable(feeRecipient).transfer(fee);
        }

        // 转版税
        // 只有版税金额 > 0 且版税地址有效时才转
        if (royalty > 0 && item.royaltyReceiver != address(0)) {
            payable(item.royaltyReceiver).transfer(royalty);
        }

        // 转卖家收入
        payable(item.seller).transfer(sellerAmount);

        // 触发购买事件
        emit Purchase(msg.sender, nftAddress, tokenId, msg.value);
    }


    /// @notice 取消上架
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 的 tokenId
    function cancelListing(address nftAddress, uint256 tokenId) external {
        // 取出上架记录
        Listing storage item = listings[nftAddress][tokenId];

        // 必须已经上架
        require(item.isListed, "Not listed");

        // 只有卖家本人可以取消上架
        require(item.seller == msg.sender, "Not seller");

        // 删除上架记录
        delete listings[nftAddress][tokenId];

        // 触发取消上架事件
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }


    // =========================================================
    // 查询功能
    // =========================================================

    /// @notice 查询某个 NFT 的上架信息
    /// @param nftAddress NFT 合约地址
    /// @param tokenId NFT 的 tokenId
    /// @return Listing 返回完整上架记录
    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return listings[nftAddress][tokenId];
    }


    // =========================================================
    // 安全限制
    // =========================================================

    /// @notice 拒绝别人直接给合约打 ETH
    receive() external payable {
        revert("No direct ETH");
    }

    /// @notice 拒绝调用不存在的函数
    fallback() external payable {
        revert("Invalid call");
    }
}

