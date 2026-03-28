// SPDX-License-Identifier: MIT              
pragma solidity ^0.8.20;                             

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";// 调用NFT所有权、转账功能
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";// 保护交易安全，防止重复攻击

contract NFTMarketplace is ReentrancyGuard {             // 创建NFT市场合约，自带安全防护

address public owner;                                    // 合约管理员（谁部署谁是老板）
uint256 public marketplaceFeePercent;                    // 平台收的手续费（100=1%）
address public feeRecipient;                            // 手续费给谁收
bool public paused;                                      // 市场是否暂停交易（true=暂停）

// 定义一个“商品货架”，存放NFT信息
struct Listing {                                         // 货架结构
    address seller;                                      // 卖家是谁
    address nftAddress;                                  // NFT合约地址
    uint256 tokenId;                                     // NFT编号
    uint256 price;                                       // 卖多少钱
    address royaltyReceiver;                             // 版税给谁（原创作者）
    uint256 royaltyPercent;                              // 版税比例（100=1%）
    bool isListed;                                       // 是否正在售卖
}

// 用NFT地址+编号找到对应商品
mapping(address => mapping(uint256 => Listing)) public listings; // 商品库存表

// 发生操作时对外发通知
event Listed(address seller, address nftAddress, uint256 tokenId, uint256 price); //NFT上架
event Purchase(address buyer, address nftAddress, uint256 tokenId, uint256 price); //NFT被买走
event Unlisted(address seller, address nftAddress, uint256 tokenId);              //取消上架
event FeeUpdated(uint256 newFee, address newRecipient);                          //手续费修改
event Paused(bool status);                                                        //市场暂停/开启

// 部署合约时只执行一次
constructor(uint256 _feePercent, address _feeRecipient) { // 初始化：设置手续费和收款人
    require(_feePercent <= 1000, "Fee too high");         // 手续费最高10%
    require(_feeRecipient != address(0), "Invalid address"); // 手续费地址不能是空

    owner = msg.sender;                                   // 部署者=管理员
    marketplaceFeePercent = _feePercent;                 // 保存手续费比例
    feeRecipient = _feeRecipient;                         // 保存手续费收款地址
}

// 通用权限/安全检查
modifier onlyOwner() {                                    // 只有管理员能用
    require(msg.sender == owner, "Only owner");           // 检查调用者是不是管理员
    _;                                                    // 执行函数内容
}

modifier notPaused() {                                    // 市场没暂停才能用
    require(!paused, "Marketplace paused");               // 检查是否暂停
    _;                                                    // 执行函数内容
}

// 管理员专用功能
function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner { // 修改手续费
    require(_newFee <= 1000, "Too high");               // 不能超过10%
    marketplaceFeePercent = _newFee;                    // 更新手续费
    emit FeeUpdated(_newFee, feeRecipient);             // 发通知：手续费已改
}

function setFeeRecipient(address _newRecipient) external onlyOwner { // 修改手续费收款人
    require(_newRecipient != address(0), "Invalid");   // 地址不能为空
    feeRecipient = _newRecipient;                       // 更新收款人
    emit FeeUpdated(marketplaceFeePercent, _newRecipient); // 发通知
}

function setPaused(bool _paused) external onlyOwner {   // 暂停/开启市场
    paused = _paused;                                   // 设置暂停状态
    emit Paused(_paused);                               // 发通知
}

// 卖家把NFT挂上去卖
function listNFT(
    address nftAddress,                                 // NFT合约地址
    uint256 tokenId,                                    // NFT编号
    uint256 price,                                      // 售价
    address royaltyReceiver,                            // 版税接收人
    uint256 royaltyPercent                              // 版税比例
) external notPaused {                                  // 市场没暂停才能上架

    require(price > 0, "Price must > 0");               // 价格必须大于0
    require(royaltyPercent <= 1000, "Max 10%");         // 版税最高10%
    require(!listings[nftAddress][tokenId].isListed, "Already listed"); // 不能重复上架

    IERC721 nft = IERC721(nftAddress);                  // 找到这个NFT

    // 必须是拥有者
    require(nft.ownerOf(tokenId) == msg.sender, "Not owner"); // 调用者必须是NFT主人

    // 必须授权市场
    require(
        nft.getApproved(tokenId) == address(this) ||
        nft.isApprovedForAll(msg.sender, address(this)),
        "Not approved"                                   // 必须允许市场代转NFT
    );

    listings[nftAddress][tokenId] = Listing({            // 把商品信息放进货架
        seller: msg.sender,                              // 卖家
        nftAddress: nftAddress,                          // NFT地址
        tokenId: tokenId,                                // NFT编号
        price: price,                                    // 价格
        royaltyReceiver: royaltyReceiver,                // 版税接收人
        royaltyPercent: royaltyPercent,                  // 版税比例
        isListed: true                                   // 标记为已上架
    });

    emit Listed(msg.sender, nftAddress, tokenId, price); // 发通知：上架成功
}

// 买家购买NFT（最关键函数）
function buyNFT(address nftAddress, uint256 tokenId)
    external
    payable                                             // 可以付ETH
    nonReentrant                                        // 防重复攻击（安全锁）
    notPaused                                           // 市场没暂停
{
    Listing storage item = listings[nftAddress][tokenId]; // 找到要购买的商品

    require(item.isListed, "Not listed");               // 必须正在售卖
    require(msg.value == item.price, "Wrong price");    // 付的钱必须等于售价

    // 再次确认NFT仍然属于卖家（防止转走）
    require(
        IERC721(nftAddress).ownerOf(tokenId) == item.seller,
        "Seller no longer owns NFT"                     // 卖家必须还持有NFT
    );

    require(
        item.royaltyPercent + marketplaceFeePercent <= 10000,
        "Fee overflow"                                   // 手续费+版税不能超过100%
    );

   // 分钱计算
    uint256 fee = (msg.value * marketplaceFeePercent) / 10000; // 平台手续费
    uint256 royalty = (msg.value * item.royaltyPercent) / 10000; // 作者版税
    uint256 sellerAmount = msg.value - fee - royalty;    // 卖家实际拿到的钱

    // 先把商品下架，防止重复买
    delete listings[nftAddress][tokenId];

     // 把NFT转给买家
    IERC721(nftAddress).safeTransferFrom(item.seller, msg.sender, tokenId);

    // 分发ETH（已修复最新安全写法）
    if (fee > 0) {
        (bool suc1,) = payable(feeRecipient).call{value: fee}("");
        require(suc1, "Fee failed");
    }

    if (royalty > 0 && item.royaltyReceiver != address(0)) {
        (bool suc2,) = payable(item.royaltyReceiver).call{value: royalty}("");
        require(suc2, "Royalty failed");
    }

    (bool suc3,) = payable(item.seller).call{value: sellerAmount}("");
    require(suc3, "Seller payment failed");

    emit Purchase(msg.sender, nftAddress, tokenId, msg.value); // 发通知：购买成功
}

/// 取消上架                                            
function cancelListing(address nftAddress, uint256 tokenId) external {

    Listing storage item = listings[nftAddress][tokenId]; // 找到商品

    require(item.isListed, "Not listed");                 // 必须正在售卖
    require(item.seller == msg.sender, "Not seller");     // 只能卖家自己取消

    delete listings[nftAddress][tokenId];                // 删除商品信息

    emit Unlisted(msg.sender, nftAddress, tokenId);       // 发通知：已取消
}

/// 查询                                               
function getListing(address nftAddress, uint256 tokenId)
    external
    view
    returns (Listing memory)
{
    return listings[nftAddress][tokenId];                 // 返回商品详情
}

// 防止恶意转账
receive() external payable {                              // 禁止直接转ETH
    revert("No direct ETH");                             // 直接转钱会被拒绝
}

fallback() external payable {                             // 禁止无效调用
    revert("Invalid call");                              // 乱调用会被拒绝
}
}
//这是一个 NFT 线上市场，任何人都能在这里买卖 NFT
//卖家上架 NFT → 设置价格、版税
//买家付钱买 NFT → 钱自动分给：卖家 + 平台 + 原创作者
//全程带安全锁，不怕黑客攻击、不怕重复转钱、不怕被骗