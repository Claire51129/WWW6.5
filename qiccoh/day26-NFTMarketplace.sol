// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//不算太会,还需琢磨

// 铸造NFT转向将它们货币化
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
/**
- **列出他们的NFT出售**，设置价格甚至自定义版税
- 通过直接向合约发送ETH来**购买NFT**
- **自动分割销售**在卖家、创作者（版税）和平台（市场费用）之间
- 随时**取消列表**
- 作为市场所有者**更新费用设置
**/
contract NFTMarketplace is ReentrancyGuard {
    // - 与任何ERC-721 NFT合约一起工作
// - 保持我们的市场免受关键漏洞的影响
    address public owner;
    uint256 public marketplaceFeePercent; // 以基点为单位 (100 = 1%)
    address public feeRecipient;

    struct Listing {
        address seller;//收款人
        address nftAddress;//合约地址
        uint256 tokenId;//NFT的ID
        uint256 price;//NFT的金额
        address royaltyReceiver;
        uint256 royaltyPercent; // 以基点为单位
        bool isListed;//NFT是否当前列出的标志
    }
/**这是一个**嵌套映射**，意味着：

- 第一个键是**NFT合约地址**
- 第二个键是**代币ID**/
    mapping(address => mapping(uint256 => Listing)) public listings;
/**
- **谁**列出了它（`seller`）
- **哪个NFT**正在被出售（`nftAddress`、`tokenId`）
- **多少钱**（`price`）
- **谁获得版税**，以及**多少**（`royaltyReceiver`、`royaltyPercent`）
**/
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    );
/**
- **买家**的地址
- 被出售的**NFT**（通过`nftAddress`和`tokenId`）
- 支付的**总价格**
- 接收ETH的**卖家**（减去费用）
- **版税接收者**（如果有）以及他们得到多少
- **市场费用金额**
**/
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
/**
当卖家**取消**他们的列表时发出。

这个事件帮助：

- UI停止显示过期或删除的列表
- 索引器更新他们的数据库
- 每个人都保持对实际出售内容的同步
**/
    event Unlisted(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
/**当**市场所有者更改费用设置**时记录此事件。

这包括：

- **新费用**（以基点为单位，例如250 = 2.5%）
- 费用ETH将被发送到的**新接收者地址**

它主要对管理面板、DAO控制的平台或用户透明度有用。**/
    event FeeUpdated(
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );


/**
- 设置市场将收取多少**费用**（例如，2.5%）
- 决定这些费用应该**去哪里**（例如，到DAO金库或开发钱包）
- 自动成为合约的**所有者/管理员**
**/
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
// 更新市场费用
/**这个函数允许**合约的所有者**更改**市场费用**（平台在每次销售中收取的百分比）。

它对以下有用：

- 随着平台增长调整费用
- 在促销期间降低费用
- 增加费用以维持运营
- 响应社区治理，如果由DAO运行**/
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }
/**- **创始人的钱包**
- **DAO金库**
- 团队管理的**多重签名**
- 甚至是进一步分割收入的**智能合约****/
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

// 列出你的NFT出售
/**- 用户拥有NFT
- NFT被批准用于市场转移
- 价格和版税设置有效
nftAddress	NFT的ERC-721合约地址
tokenId	你正在列出的NFT的唯一ID
price	你想要出售的ETH数量（以wei为单位）
royaltyReceiver	应该在销售中接收版税的地址
royaltyPercent	给予多少版税（以基点为单位，例如，500 = 5%）**/
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
/**- 你必须以**非零价格**列出
- 版税必须**≤10%**以保持合理
- NFT必须**尚未列出**（以避免覆盖或重复条目）**/
        IERC721 nft = IERC721(nftAddress);
        /**
        我们将地址转换为`IERC721`合约接口，以便我们可以调用标准ERC-721函数，如：
- `ownerOf`
- `getApproved`
- `isApprovedForAll`
        **/
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


// 用ETH购买NFT
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
            payable(feeRecipient).transfer(feeAmount);
        }

        // 创作者版税
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
            payable(item.royaltyReceiver).transfer(royaltyAmount);
        }

        // 卖家支付
        payable(item.seller).transfer(sellerAmount);

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


// 从销售中移除NFT
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }
// 查看列表详细信息
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

