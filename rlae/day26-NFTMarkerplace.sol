// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; //这是非同质化代币（NFT）使用的标准
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //安全工具，帮助保护我们的合约免受称为重入攻击的常见黑客攻击,使用ReentrancyGuard，我们可以锁定我们的敏感函数，如buyNFT()，这样没有人可以重新进入并在中途利用逻辑
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
contract NFTMarketplace is ReentrancyGuard { //从ReentrancyGuard继承
    address public owner;
    uint256 public marketplaceFeePercent; // 以基点为单位 (100 = 1%) 市场将从每次销售中收取的费用百分比——但以基点为单位
    address public feeRecipient; //每次NFT销售中接收市场份额的钱包
    struct Listing { // Listing结构体-市场上列出的单个NFT的迷你数据库条目
    address seller;
    address nftAddress; //是NFT的合约地址
    uint256 tokenId; //被列出的NFT的ID
    uint256 price; //卖家想要NFT的金额（以ETH为单位）
    address royaltyReceiver; //接收创作者版税的地址,允许创作者继续从二次销售中赚钱，即使他们不再是卖家
    uint256 royaltyPercent; // 以基点为单位,应该获得多少版税
    bool isListed; //NFT是否listed
    }
    mapping(address => mapping(uint256 => Listing)) public listings; //listings[nftAddress][tokenId]
    event Listed( //NFT被列出出售时发出此事件
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    address royaltyReceiver,
    uint256 royaltyPercent
    );
    event Purchase( //当有人购买NFT时触发此事件
    address indexed buyer,
    address indexed nftAddress,
    uint256 indexed tokenId,
    uint256 price,
    address seller,
    address royaltyReceiver,
    uint256 royaltyAmount, //版税接收者（如果有）以及他们得到多少
    uint256 marketplaceFeeAmount //市场费用金额
    );
    event Unlisted( //当卖家取消他们的list时发出
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed tokenId
    );
    event FeeUpdated( //当市场所有者更改费用设置时记录此事件
    uint256 newMarketplaceFee,
    address newFeeRecipient
    );
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {
    require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)"); //防止在部署时设置疯狂的费用设置
    require(_feeRecipient != address(0), "Fee recipient cannot be zero"); //确保部署者传入一个有效的ETH地址来接收市场费用

    owner = msg.sender;
    marketplaceFeePercent = _marketplaceFeePercent;
    feeRecipient = _feeRecipient;
    }
    modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;
    }
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {
    //允许合约的所有者更改市场费用（平台在每次销售中收取的百分比
    //external：意味着这个函数是为了从合约外部调用（比如通过前端或由所有者直接调用）
    require(_newFee <= 1000, "Marketplace fee too high");
    marketplaceFeePercent = _newFee;
    emit FeeUpdated(_newFee, feeRecipient);
    }
    function setFeeRecipient(address _newRecipient) external onlyOwner {
    require(_newRecipient != address(0), "Invalid fee recipient");
    feeRecipient = _newRecipient; //更新合约的内部状态——现在所有未来的市场费用将被发送到这个新地址
    emit FeeUpdated(marketplaceFeePercent, _newRecipient);
    }
    //列出你的NFT出售
    function listNFT(
    address nftAddress, //NFT的ERC-721合约地址
    uint256 tokenId,
    uint256 price,
    address royaltyReceiver,
    uint256 royaltyPercent
    ) external {
    require(price > 0, "Price must be above zero");
    require(royaltyPercent <= 1000, "Max 10% royalty allowed"); //版税必须**≤10%**以保持合理
    require(!listings[nftAddress][tokenId].isListed, "Already listed"); //NFT必须尚未列出（以避免覆盖或重复条目）

    IERC721 nft = IERC721(nftAddress); //与NFT交互
    require(nft.ownerOf(tokenId) == msg.sender, "Not the owner"); //确保调用者实际拥有他们试图列出的NFT
    require(
        nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
        "Marketplace not approved" //市场必须被批准代表用户转移NFT
    );
    //创建一个Listing结构体并将其存储在我们的嵌套listings映射中
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
    //使用ReentrancyGuard防止重入攻击
    //从存储中获取列表到内存中
    Listing memory item = listings[nftAddress][tokenId];
    require(item.isListed, "Not listed");
    require(msg.value == item.price, "Incorrect ETH sent");
    require(
        item.royaltyPercent + marketplaceFeePercent <= 10000, //组合版税+平台费用是否保持在100%以下
        "Combined fees exceed 100%"
    );
    //总ETH（msg.value）分成三个part

    uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;
    uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;
    uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;

    // 支付市场
    if (feeAmount > 0) {
        payable(feeRecipient).transfer(feeAmount);//ETH去feeRecipient——这可能是平台、DAO，甚至开发钱包
    }

    // 支付创作者版税
    if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {
        payable(item.royaltyReceiver).transfer(royaltyAmount);
    }

    // 支付卖家
    payable(item.seller).transfer(sellerAmount);

    // 将NFT转移给买家 //合约使用标准ERC-721转移函数将NFT从卖家移动到买家
    IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);
    //safeTransferFrom 会检查该合约是否实现了 onERC721Received 接口
    //item.seller：NFT 的当前拥有者（卖家
    //msg.sender：发起这笔交易的人（买家）
    //item.tokenId：要转移的那枚特定 NFT 的唯一编号

    // 清理列表
    delete listings[nftAddress][tokenId]; //一旦NFT被出售，我们从存储中删除列表，这样它就不再显示

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
    require(item.isListed, "Not listed"); //如果NFT没有列出，你不能取消它
    require(item.seller == msg.sender, "Not the seller"); //只有原始卖家可以取消他们的列表

    delete listings[nftAddress][tokenId];
    emit Unlisted(msg.sender, nftAddress, tokenId);
    }
    //查看列表详细信息
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
    return listings[nftAddress][tokenId];
    //返回给定NFT的完整Listing结构体
    }
    //拒绝直接ETH转账,当有人直接向合约发送ETH而不调用函数时触发此函数
    receive() external payable {
    revert("Direct ETH not accepted");
    }
    //fallback()在以下情况下被调用-有人调用合约中不存在的函数 or 在不触发receive()的情况下发送ETH
    //确保用户不会因为调用像byuNFT()而不是buyNFT()这样的拼写错误而丢失ETH
    fallback() external payable {
    revert("Unknown function");
    }








}