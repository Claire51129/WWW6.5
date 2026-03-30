
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";    //ERC721为NFT常见标准，“帮我接入NFT标准接口”
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";   //导入了一个安全工具：ReentrancyGuard(用来防止一种叫重入攻击的经典攻击)

contract NFTMarketplace is ReentrancyGuard {   //定义新合约，名字叫NFT市场合约；该合约继承ReentrancyGuard 的安全能力
    address public owner;   //记录这个市场是谁开的(外面的人也能看到)
    uint256 public marketplaceFeePercent; // 定义了平台手续费比例：以基点为单位 (100 = 1%)(可以更精确，不容易有小数点麻烦)
    address public feeRecipient;   //平台收钱地址，“平台手续费最后要打给谁”

    struct Listing {   //定义一个交listing的数据组，用于记录较多信息
        address seller;   //卖家地址，列出NFT的人，他们将是接收大部分收款的人(在扣掉市场费用和版税后)“谁在卖这个 NFT”
        address nftAddress;   //NFT合约地址，“这个NFT(代币)是哪一个 NFT 合约里的。”
        uint256 tokenId;   //NFT的ID/编号(同一个 NFT 合约里可能有很多 NFT，tokenId 就像每张 NFT 的身份证号)
        uint256 price;   //价格，“这个 NFT 卖多少钱”(以ETH为单位)
        address royaltyReceiver;    //版税接收人地址，“如果这个 NFT 交易时要给创作者分成，那钱给谁”
        uint256 royaltyPercent; // 版税比例(以基点为单位)
        bool isListed;   //“这个 NFT 现在是不是已经挂出来卖了”
    }    //bool 只有两种值：true = 是，false = 否

    //嵌套映射——可以把它理解成一个双层抽屉柜：第一层抽屉：NFT 合约地址;第二层抽屉：tokenId,抽屉里装的内容：Listing
    mapping(address => mapping(uint256 => Listing)) public listings;    //定义一个大仓库listings，用来保存所有挂单；“某个 NFT 合约里的某个 tokenId，对应一份挂单信息。”

    event Listed(   //有人挂单了
        address indexed seller,   //事件里记录卖家地址；indexed的意思是更方便搜索
        address indexed nftAddress,   //记录NFT合约地址，也方便查
        uint256 indexed tokenId,   //记录 NFT 编号，也方便查
        uint256 price,   //记录价格
        address royaltyReceiver,   //记录版税收款人(谁获得版税)
        uint256 royaltyPercent   //记录版税比例
    );

    event Purchase(    //定义一个事件：有人购买成功
        address indexed buyer,   //记录卖家地址
        address indexed nftAddress,    //记录NFT合约地址
        uint256 indexed tokenId,    //记录 NFT 编号
        uint256 price,    //记录成交价格
        address seller,    //记录卖家(减去费用)
        address royaltyReceiver,    //记录版税接收人
        uint256 royaltyAmount,    //记录实际分了多少版税金额
        uint256 marketplaceFeeAmount    //记录平台实际抽了多少手续费
    );   //对以下有用：前端显示购买收据、显示市场收入的分析仪表板、创作者版税报告

    event Unlisted(    //定义一个事件:下架了
        address indexed seller,    //记录是谁下架的
        address indexed nftAddress,    //记录哪个 NFT 合约
        uint256 indexed tokenId    //记录哪个 NFT 编号
    );   //这个事件帮助：UI停止显示过期或删除的列表、索引器更新他们的数据库、每个人都保持对实际出售内容的同步

    event FeeUpdated(   //平台手续费设置改了
        uint256 newMarketplaceFee,   //记录新的手续费比例
        address newFeeRecipient    //记录新的手续费接收地址
    );    //主要对管理面板、DAO控制的平台或用户透明度有用。

    // 构造函数:初始化设置
    constructor(uint256 _marketplaceFeePercent, address _feeRecipient) {   //部署合约时，必须先传两个参数进来：平台手续费比例、平台收款地址
        require(_marketplaceFeePercent <= 1000, "Marketplace fee too high (max 10%)");    //“平台手续费不能超过 10%”(1000 基点 = 10%)
        require(_feeRecipient != address(0), "Fee recipient cannot be zero");   //address(0) 就像“无效地址”“空气地址”；“平台收款地址不能是空地址”

        owner = msg.sender;    //msg.sender = 当前调用这个函数的人;“谁来部署这个合约，谁就是管理员”
        marketplaceFeePercent = _marketplaceFeePercent;   //把传进来的手续费比例，保存到合约里。
        feeRecipient = _feeRecipient;   //把传进来的手续费收款地址，保存到合约里。
    }   //marketplaceFeePercent：平台从每次销售中收取多少；feeRecipient：费用发送到哪里

    modifier onlyOwner() {   //权限控制：定义一个修改器onlyOwner，“只有管理员才能进来执行某些函数。”
        require(msg.sender == owner, "Only owner");   //检查现在调用的人是不是管理员
        _;   //“前面的检查通过后，继续执行函数的其余部分。”
    }

    // 管理员修改平台手续费(更新市场费用)
    function setMarketplaceFeePercent(uint256 _newFee) external onlyOwner {  //定义一个函数：设置新的平台手续费比例；
        require(_newFee <= 1000, "Marketplace fee too high");   //新手续费不能超过 10%
        marketplaceFeePercent = _newFee;   //把新的手续费存起来
        emit FeeUpdated(_newFee, feeRecipient);   //宣布：“手续费变了，收款地址还是当前这个地址。”
    }  //作用：随着平台增长调整费用、在促销期间降低费用、增加费用以维持运营、响应社区治理，如果由DAO运行

    // 管理员修改平台收款地址(更新市场费用去向)
    function setFeeRecipient(address _newRecipient) external onlyOwner {   //只有管理员可以改
        require(_newRecipient != address(0), "Invalid fee recipient");   //新地址不能为空地址
        feeRecipient = _newRecipient;   //保存新地址
        emit FeeUpdated(marketplaceFeePercent, _newRecipient);   //广播通知：“收款地址改了，手续费比例还是现在这个数。”
    }   //在任何NFT市场中，费用接收者是收集市场每次销售份额的地址。这可能是：创始人的钱包、DAO金库、团队管理的多重签名、甚至是进一步分割收入的智能合约。这个函数让市场随时间适应——无论是为了安全升级、去中心化，还是将收入转移到社区控制的合约

    // 挂单函数：“把 NFT 拿来挂牌卖”
    function listNFT(   //挂NFT
        address nftAddress,   //NFT的ERC721合约地址
        uint256 tokenId,   //NFT编号
        uint256 price,   //售价
        address royaltyReceiver,   //版税接收人地址
        uint256 royaltyPercent   //版税比例
    ) external {    //这个函数外部可调用，即卖家可以自己来挂单
        require(price > 0, "Price must be above zero");   //售出价格必须大于0
        require(royaltyPercent <= 1000, "Max 10% royalty allowed");   //版税比例最多10%
        require(!listings[nftAddress][tokenId].isListed, "Already listed");   //检查这个 NFT 现在是不是已经挂过了；!表示"不是"；“如果它已经在卖了，就不能重复挂单。”

        IERC721 nft = IERC721(nftAddress);   //与NFT交互：把 nftAddress 当成 ERC721 NFT 合约来使用,“我现在要把这个地址，当成一个 NFT 合约对象来操作。”
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");   //检查当前挂单的人，是不是真的拥有这个 NFT；nft.ownerOf(tokenId) = 这个 NFT 现在的主人是谁
        require(    //市场合约必须先得到 NFT 主人的授权，才能在成交时帮忙转 NFT。这里检查两种授权方式，只要满足一种就行：
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),    //这个单独的 tokenId 已经授权给市场合约 或者 卖家把自己所有 NFT 都授权给市场合约管理 两者均可，
            "Marketplace not approved"   //←否则报错""
        );    //“虽然 NFT 是你的，但你还没给市场机器人开搬运权限，所以它不能帮你卖。”

        listings[nftAddress][tokenId] = Listing({   //把挂单信息写进仓库里：“这个 NFT 现在正式上架了。”
            seller: msg.sender,   //卖家 = 当前调用挂单函数的人。
            nftAddress: nftAddress,   //保存 NFT 合约地址。
            tokenId: tokenId,   //保存NFT编号
            price: price,   //保存价格
            royaltyReceiver: royaltyReceiver,   //保存版权税收款人
            royaltyPercent: royaltyPercent,    //保存版权税比例
            isListed: true   //标记为：已经挂牌中
        });    //创建一个Listing结构体并将其存储在我们的嵌套listings映射中。这现在是市场上的实时列表——任何人都可以发现。——挂单信息写入完成

        emit Listed(msg.sender, nftAddress, tokenId, price, royaltyReceiver, royaltyPercent);   //广播“挂单成功”事件
    }   //在链上记录列表，以便：UI可以显示它、索引器（如The Graph）可以跟踪它、用户可以实时看到活动

    // 【市场核心】用ETH购买NFT：接受买家的ETH、在卖家、创作者（版税）和平台（费用）之间分割、将NFT转移给买家、删除列表、发出事件让世界知道购买发生了(全部在一个交易中。没有手动步骤。没有链下确认。)
    function buyNFT(address nftAddress, uint256 tokenId) external payable nonReentrant {   //payable 表示这个函数可以带 ETH 进来,因为买家要付钱;nonReentrant 表示开启防重入保护,就像：“买东西时门一次只能进一个人，不能钻漏洞连买带偷。”
        Listing memory item = listings[nftAddress][tokenId];   //加载列表：我们从存储中获取列表到内存中，以便我们可以读取其详细信息（价格、卖家、版税信息等）。把挂单信息从仓库里拿出来，放到一个临时变量 item 里；memory 可以理解成“临时抄一份到桌上看”
        require(item.isListed, "Not listed");   //检查这个 NFT 真的在售卖中
        require(msg.value == item.price, "Incorrect ETH sent");   //检查买家发来的 ETH 金额是不是刚好等于价格;msg.value = 这次调用一起带进来的 ETH
        require(   //检查版税比例 + 平台手续费比例，加起来不能超过 100%
            item.royaltyPercent + marketplaceFeePercent <= 10000,
            "Combined fees exceed 100%"
        );    //(因为10000 基点 = 100%，如果超过了，就会出现“钱分不够”的问题)

        uint256 feeAmount = (msg.value * marketplaceFeePercent) / 10000;   //计算市场费用/平台手续费金额:成交价 × 平台手续费比例 ÷ 10000
        uint256 royaltyAmount = (msg.value * item.royaltyPercent) / 10000;   //计算版税金额:比如版税10%，成交价1，那版税为0.1ETH
        uint256 sellerAmount = msg.value - feeAmount - royaltyAmount;   //计算卖家最后真正拿到的钱：买家付的钱 - 平台手续费 - 版税 = 卖家所得

        // 市场费用：下面要处理平台手续费
        if (feeAmount > 0) {    //如果平台手续费大于 0，才真的转钱
            (bool feeSuccess, ) = payable(feeRecipient).call{value: feeAmount}("");   //把平台手续费打给平台收款地址
            require(feeSuccess, "Fee transfer failed");   //如果刚才转账失败，就立刻报错并停止
        }   //payable(...) 的意思是：把这个地址变成“可以收 ETH 的地址”。;transfer = 转账

        // 支付创作者版税——只有两个条件都满足才转版税：
        if (royaltyAmount > 0 && item.royaltyReceiver != address(0)) {   //版税金额大于0&版税收款地址不是空地址
            (bool royaltySuccess, ) = payable(item.royaltyReceiver).call{value: royaltyAmount}("");   //“把版税金额打给版税接收地址，并记录有没有成功。”
            require(royaltySuccess, "Royalty transfer failed");    //“如果版税没转成功，就停止整笔交易。”
        }   //版税分账结束：费用和版税后剩下的任何东西都归列出NFT的人

        // 卖家支付：把卖家赢得的钱转给卖家
        (bool sellerSuccess, ) = payable(item.seller).call{value: sellerAmount}("");    //“把卖家应该收到的钱打给卖家，并记录成功还是失败。”
        require(sellerSuccess, "Seller transfer failed");    //“如果卖家收款失败，就报错。”

        // 将NFT转移给买家——item.seller = 原主人；msg.sender = 当前买家；item.tokenId = 这个 NFT 编号；safeTransferFrom 是 ERC721 安全转账方法。
        IERC721(item.nftAddress).safeTransferFrom(item.seller, msg.sender, item.tokenId);   //合约使用标准ERC-721转移函数将NFT从卖家移动到买家(这只有在卖家在列表期间批准市场时才有效)。“付完钱后，市场机器人正式把商品交给买家。”

        // 删除列表:交易完成后要删掉挂单
        delete listings[nftAddress][tokenId];   //把这个 NFT 的挂单信息从仓库里删除

        emit Purchase(   //广播购买成功事件
            msg.sender,   //记录买家地址
            nftAddress,   //记录NFT合约地址
            tokenId,   //记录NFT编号
            msg.value,   //记录买家实际支付金额
            item.seller,   //记录卖家地址
            item.royaltyReceiver,   //记录版税接收人地址
            royaltyAmount,   //记录实际版税金额
            feeAmount   //记录平添手续费金额
        );
    }

    // 取消挂单：“我不卖了，下架”
    function cancelListing(address nftAddress, uint256 tokenId) external {   //传入NFT地址、tokenId
        Listing memory item = listings[nftAddress][tokenId];   //先把这笔挂单拿出来看
        require(item.isListed, "Not listed");   //先确认它现在真的在挂单
        require(item.seller == msg.sender, "Not the seller");   //检查当前调用的人是不是卖家本人

        delete listings[nftAddress][tokenId];   //删除挂单信息
        emit Unlisted(msg.sender, nftAddress, tokenId);   //nftAddress = NFT的合约;tokenId = 被取消列出的特定NFT
    }   //该函数在以下情况下有用：你改变了出售的想法、你想以新价格重新列出、你意外列出了错误的NFT、

    // 只读辅助函数：查询挂单(查看列表详细信息)
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {   //returns (Listing memory) 表示会返回一份挂单信息
        return listings[nftAddress][tokenId];   //把这个 NFT 当前的挂单信息返回出去(前端页面可用这个函数读取详情)
    }   //什么时候用：市场前端想要显示列出NFT的所有详细信息、买家想要在购买前预览价格和版税、脚本或机器人想要检查列出的内容并过滤交易

    // 特殊函数：拒绝直接ETH转账——更安全，避免有人误转账
    receive() external payable {   //当别人什么函数都不调，只是直接往合约地址打 ETH 的时候，会自动运行该函数
        revert("Direct ETH not accepted");   //“这个市场合约不接受你莫名其妙直接打钱进来。”
    }   //当有人直接向合约发送ETH而不调用函数时触发此函数。防止：意外的ETH转账、用户认为他们只是通过发送ETH就在购买东西、ETH永远卡在合约中

    // 特殊函数fallback()——拒绝未知函数调用：当别人调用了一个根本不存在的函数时，该函数自动运行(安全保护)
    fallback() external payable {
        revert("Unknown function");   //自动报错：“你调用了未知函数。”
    }
}




// struct: 可以理解成一个“信息包”或者“表格模板”或“数据库条目”
// 自动NFT商城机器人：1创建市场→2卖家挂单→3买家购买。 然后市场检查→自动分钱。→4卖家取消挂单
// 【一句话总结】“卖家先授权并挂单，买家付款后，合约自动分钱并自动把 NFT 交给买家。”
// external：意味着这个函数是为了从合约外部调用（比如通过前端或由所有者直接调用）