
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//导入ERC721标准
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//导入重入攻击防御
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

//继承重入攻击防御
contract NFTMarketplace is ReentrancyGuard {
    address public owner;
    uint256 public marketplaceFeePercent; // 以基点为单位 (100 = 1%)
    //费用的去向，可能是合约的拥有者
    address public feeRecipient;

    //单个NFT的迷你数据库条目
    struct Listing {
        //接收大部分付款的人（在市场费用和版税之后）
        address seller;
        //NFT的合约地址。
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        //可选：应该从此次销售中接收创作者版税的地址。
        address royaltyReceiver;
        //版税百分比
        uint256 royaltyPercent; // 以基点为单位
        //是否列出
        bool isListed;
    }
    //NFC合约 => 代币ID => 对应数据库中的代币
    mapping(address => mapping(uint256 => Listing)) public listings;
    //当NFT被列出出售时发出此事件
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
    //代币下架？
    event Unlisted(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    //更新费用
    event FeeUpdated(
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );
    //规定时长手续费，手续费发给谁
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
    //设置交易费用
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }
    //设置交易费接收地址
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }
    //NFT上架
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

        //定义接口nft
        IERC721 nft = IERC721(nftAddress);
        //只有代币的主人才允许上架代币
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        //代币要可以被本合约处理
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
    //购买代币
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
    //商品下架
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
    //不接受直接转账
    receive() external payable {
        revert("Direct ETH not accepted");
    }
    //调用不存在的函数就回滚交易
    fallback() external payable {
        revert("Unknown function");
    }
}

