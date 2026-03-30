// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IERC721
 * @dev 手动定义 ERC721 接口（只需本合约用到的函数）
 */
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

/**
 * @title ReentrancyGuard
 * @dev 手动实现简单的重入锁
 */
abstract contract ReentrancyGuard {
    uint256 private _status;

    constructor() {
        _status = 1;
    }

    modifier nonReentrant() {
        require(_status != 2, "Reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

/**
 * @title NFTMarketplace
 * @notice 去中心化NFT市场，支持上架、购买、取消挂单，以及买家出价功能
 */
contract NFTMarketplace is ReentrancyGuard {
    // ========== 状态变量 ==========
    address public owner;                      // 合约所有者（管理员）
    uint256 public marketplaceFeePercent;      // 平台手续费百分比（例如 2 表示 2%）
    address public feeRecipient;               // 手续费接收地址

    struct Listing {
        address seller;          // 卖家地址
        address nftContract;     // NFT合约地址
        uint256 tokenId;         // NFT的ID
        uint256 price;           // 售价（wei）
        uint256 royaltyPercent;  // 版税百分比（例如 5 表示 5%）
    }

    // 出价结构体
    struct Offer {
        address bidder;          // 出价人地址
        uint256 amount;          // 出价金额（wei）
        uint256 timestamp;       // 出价时间
    }

    // 挂单ID => 挂单信息
    mapping(bytes32 => Listing) public listings;
    // 挂单ID => 出价数组（允许同一个挂单有多个出价）
    mapping(bytes32 => Offer[]) public offers;

    // 事件
    event Listed(
        bytes32 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 royaltyPercent
    );
    event Purchase(
        bytes32 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );
    event Unlisted(bytes32 indexed listingId);
    event FeeUpdated(uint256 newFeePercent);
    event FeeRecipientUpdated(address newRecipient);

    // 出价相关事件
    event OfferPlaced(
        bytes32 indexed listingId,
        address indexed bidder,
        uint256 amount
    );
    event OfferWithdrawn(
        bytes32 indexed listingId,
        address indexed bidder,
        uint256 amount
    );
    event OfferAccepted(
        bytes32 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );

    // ========== 修饰符 ==========
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // ========== 构造函数 ==========
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 100, "Fee too high");
        require(_feeRecipient != address(0), "Invalid recipient");
        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    // ========== 核心功能：上架 / 购买 / 取消 ==========
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
            "Not approved"
        );

        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, msg.sender));
        require(listings[listingId].price == 0, "Already listed");

        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            royaltyPercent: royaltyPercent
        });

        emit Listed(listingId, msg.sender, nftContract, tokenId, price, royaltyPercent);
    }

    function buyNFT(bytes32 listingId) external payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(listing.price > 0, "Not listed");
        require(msg.value == listing.price, "Incorrect price");

        delete listings[listingId];
        // 同时清除该挂单的所有出价（因为已售出）
        _clearOffers(listingId);

        uint256 marketplaceFee = (listing.price * marketplaceFeePercent) / 100;
        uint256 royaltyFee = (listing.price * listing.royaltyPercent) / 100;
        uint256 sellerProceeds = listing.price - marketplaceFee - royaltyFee;

        IERC721(listing.nftContract).transferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        if (marketplaceFee > 0) {
            payable(feeRecipient).transfer(marketplaceFee);
        }
        if (royaltyFee > 0) {
            payable(listing.seller).transfer(royaltyFee);
        }
        payable(listing.seller).transfer(sellerProceeds);

        emit Purchase(listingId, msg.sender, listing.seller, listing.price);
    }

    function cancelListing(bytes32 listingId) external {
        Listing memory listing = listings[listingId];
        require(listing.seller == msg.sender, "Not seller");
        delete listings[listingId];
        // 清除该挂单的所有出价，并将资金退还给各出价人
        _clearOffers(listingId);
        emit Unlisted(listingId);
    }

    // ========== 出价功能 ==========
    /**
     * @notice 买家对某个挂单出价（出价金额必须小于挂单价格）
     * @param listingId 挂单ID
     * @param amount 出价金额（wei）
     */
    function makeOffer(bytes32 listingId, uint256 amount) external payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(listing.price > 0, "Listing not exists");
        require(amount < listing.price, "Offer must be lower than price");
        require(msg.value == amount, "Incorrect amount sent");
        require(msg.sender != listing.seller, "Seller cannot offer");

        // 检查是否已经出价过（避免重复出价，这里简单限制每个买家只能有一个活跃出价）
        Offer[] storage listingOffers = offers[listingId];
        for (uint i = 0; i < listingOffers.length; i++) {
            require(listingOffers[i].bidder != msg.sender, "Already offered");
        }

        listingOffers.push(Offer({
            bidder: msg.sender,
            amount: amount,
            timestamp: block.timestamp
        }));

        emit OfferPlaced(listingId, msg.sender, amount);
    }

    /**
     * @notice 买家撤销自己的出价，收回资金
     * @param listingId 挂单ID
     */
    function withdrawOffer(bytes32 listingId) external nonReentrant {
        Offer[] storage listingOffers = offers[listingId];
        uint256 refundAmount = 0;
        uint256 indexToRemove = 0;
        bool found = false;

        // 找到该买家的出价
        for (uint i = 0; i < listingOffers.length; i++) {
            if (listingOffers[i].bidder == msg.sender) {
                refundAmount = listingOffers[i].amount;
                indexToRemove = i;
                found = true;
                break;
            }
        }
        require(found, "No offer found");

        // 删除出价记录（将最后一个元素移到当前位置，再pop）
        if (indexToRemove != listingOffers.length - 1) {
            listingOffers[indexToRemove] = listingOffers[listingOffers.length - 1];
        }
        listingOffers.pop();

        // 退款
        payable(msg.sender).transfer(refundAmount);
        emit OfferWithdrawn(listingId, msg.sender, refundAmount);
    }

    /**
     * @notice 卖家接受某个买家的出价，完成交易
     * @param listingId 挂单ID
     * @param bidder 出价人地址
     */
    function acceptOffer(bytes32 listingId, address bidder) external nonReentrant {
        Listing memory listing = listings[listingId];
        require(listing.seller == msg.sender, "Not seller");
        require(listing.price > 0, "Listing not exists");

        // 查找该出价
        Offer[] storage listingOffers = offers[listingId];
        uint256 offerAmount = 0;
        uint256 indexToRemove = 0;
        bool found = false;
        for (uint i = 0; i < listingOffers.length; i++) {
            if (listingOffers[i].bidder == bidder) {
                offerAmount = listingOffers[i].amount;
                indexToRemove = i;
                found = true;
                break;
            }
        }
        require(found, "Offer not found");

        // 删除出价记录
        if (indexToRemove != listingOffers.length - 1) {
            listingOffers[indexToRemove] = listingOffers[listingOffers.length - 1];
        }
        listingOffers.pop();

        // 删除挂单
        delete listings[listingId];

        // 计算费用（基于实际成交价 offerAmount）
        uint256 marketplaceFee = (offerAmount * marketplaceFeePercent) / 100;
        uint256 royaltyFee = (offerAmount * listing.royaltyPercent) / 100;
        uint256 sellerProceeds = offerAmount - marketplaceFee - royaltyFee;

        // 转移NFT
        IERC721(listing.nftContract).transferFrom(
            listing.seller,
            bidder,
            listing.tokenId
        );

        // 分配资金
        if (marketplaceFee > 0) {
            payable(feeRecipient).transfer(marketplaceFee);
        }
        if (royaltyFee > 0) {
            payable(listing.seller).transfer(royaltyFee);
        }
        payable(listing.seller).transfer(sellerProceeds);

        // 注意：出价资金已在 makeOffer 时转入合约，这里不需要额外转账给卖家
        // 合约余额应包含所有出价资金，卖家已收到应得部分，剩余部分（如有差额）留在合约中？
        // 实际上，offerAmount 已经全部在合约里，卖家拿到 sellerProceeds，剩余的是手续费和版税。
        // 没有额外退款问题。

        // 清除该挂单的其他出价，并将资金退还给其他出价人
        for (uint i = 0; i < listingOffers.length; i++) {
            address otherBidder = listingOffers[i].bidder;
            uint256 otherAmount = listingOffers[i].amount;
            payable(otherBidder).transfer(otherAmount);
        }
        // 清空出价数组
        delete offers[listingId];

        emit OfferAccepted(listingId, bidder, listing.seller, offerAmount);
    }

    // ========== 辅助函数 ==========
    /**
     * @dev 清除某个挂单的所有出价，并退款给所有出价人（当挂单被取消或直接购买时调用）
     * @param listingId 挂单ID
     */
    function _clearOffers(bytes32 listingId) private {
        Offer[] storage listingOffers = offers[listingId];
        for (uint i = 0; i < listingOffers.length; i++) {
            payable(listingOffers[i].bidder).transfer(listingOffers[i].amount);
        }
        delete offers[listingId];
    }

    // ========== 查询函数 ==========
    /**
     * @notice 获取某个挂单的所有出价
     * @param listingId 挂单ID
     * @return 出价数组
     */
    function getOffers(bytes32 listingId) external view returns (Offer[] memory) {
        return offers[listingId];
    }

    /**
     * @notice 获取某个买家对某个挂单的出价金额（如果没有出价则返回0）
     * @param listingId 挂单ID
     * @param bidder 买家地址
     * @return 出价金额
     */
    function getOfferAmount(bytes32 listingId, address bidder) external view returns (uint256) {
        Offer[] storage listingOffers = offers[listingId];
        for (uint i = 0; i < listingOffers.length; i++) {
            if (listingOffers[i].bidder == bidder) {
                return listingOffers[i].amount;
            }
        }
        return 0;
    }

    // ========== 管理员功能 ==========
    function setMarketplaceFeePercent(uint256 _newFeePercent) external onlyOwner {
        require(_newFeePercent <= 100, "Fee too high");
        marketplaceFeePercent = _newFeePercent;
        emit FeeUpdated(_newFeePercent);
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid address");
        feeRecipient = _newRecipient;
        emit FeeRecipientUpdated(_newRecipient);
    }

    // ========== Fallback 函数 ==========
    receive() external payable {
        revert("Direct payments not accepted");
    }

    fallback() external payable {
        revert("Invalid function call");
    }
}
