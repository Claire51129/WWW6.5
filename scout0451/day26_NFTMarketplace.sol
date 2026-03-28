// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    address public owner;
    uint256 public marketplaceFeePercent; // 以基点为单位 (100 = 1%)
    address public feeRecipient;

    //单个NFT的迷你数据库条目
    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        address royaltyReceiver;//从此次销售中接收创作者版税的地址
        uint256 royaltyPercent; // 以基点为单位
        bool isListed;//NFT是否当前列出
    }

    //NFT地址和代币ID的嵌套映射，多个不同的NFT收藏全部在一个合约中
    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(    //NFT被列出出售时
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address royaltyReceiver,
        uint256 royaltyPercent
    );

    event Purchase(  //有人购买NFT时
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        address seller,
        address royaltyReceiver,
        uint256 royaltyAmount,
        uint256 marketplaceFeeAmount
    );

    event Unlisted(  //卖家取消他们的列表时
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event FeeUpdated(  //市场所有者更改费用设置时
        uint256 newMarketplaceFee,
        address newFeeRecipient
    );

    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");

        owner = msg.sender;
        marketplaceFeePercent = _marketplaceFeePercent;
        feeRecipient = _feeRecipient;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;   //如果require检查通过，现在继续运行函数的其余部分。  
    }

    //更新市场费用
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Marketplace fee too high");
        marketplaceFeePercent = _newFee;
        emit FeeUpdated(_newFee, feeRecipient);
    }

    //更新市场费用去向
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }

    //列出你的NFT出售
    function listNFT(
        address nftAddress, //NFT的ERC-721合约地址
        uint256 tokenId,  //正在列出的NFT的唯一ID
        uint256 price,    //想要出售的ETH数量（以wei为单位）
        address royaltyReceiver,//在销售中接收版税的地址
        uint256 royaltyPercent  //给予多少版税（以基点为单位
    ) external {
        require(price > 0, "Price must be above zero");
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");
        require(!listings[nftAddress][tokenId].isListed, "Already listed");//NFT必须尚未列出

        IERC721 nft = IERC721(nftAddress);//将地址转换为IERC721合约接口
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");//调用者实际拥有他们列出的NFT
        require( //NFT或者操作者授权给当前合约
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        //Listing结构体并将其存储在我们的嵌套listings映射中
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

    //用ETH购买NFT
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nftAddress][tokenId];//从存储中获取列表到内存中
        require(item.isListed, "Not listed");//检查NFT已列出
        require(msg.value == item.price, "Incorrect ETH sent");//买家发送ETH=确切的NFT价格
        require( //版税+平台费<=100%
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Combined fees exceed 100%"
        );

        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;  //平台费
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

        // 使用标准ERC-721转移函数将NFT转移给买家
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);

        // 删除列表，不再显示为"出售"
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

    //卖家在出售之前从市场中移除
    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Not listed");
        require(item.seller == msg.sender, "Not the seller");

        delete listings[nftAddress][tokenId];
        emit Unlisted(msg.sender, nftAddress, tokenId);
    }

    //获取特定列表的详细信息
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return listings[nftAddress][tokenId];
    }

    //调用revert()拒绝直接向合约转账ETH
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    //防止意外误用
    fallback() external payable {
        revert("Unknown function");
    }
}

