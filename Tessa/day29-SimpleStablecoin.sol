// 数字美元自动售货机("稳定币工厂"合约)：先拿别的代币来做“押金”，合约再发给你一种叫 sUSD 的稳定币。以后你把 sUSD 还回来，合约再把押金退给你。它还会看“价格机”（预言机）告诉它押金值多少钱。
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";   //导入 ERC20 标准代币模板：我们要做的稳定币 sUSD，本身就是一种代币(这一行相当于先把“代币基础工具箱”拿进来)
import "@openzeppelin/contracts/access/Ownable.sol";   //导入 Ownable，也就是“有主人”的功能；“这个合约会有一个管理员，有些功能只有管理员能做”(像一个教室里，老师有特别权限)
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";   //导入“防重入攻击保护”
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";   //导入安全版 ERC20 工具,以后转抵押代币的时候，用更安全的方法，不容易出问题。(像是普通门锁升级成更安全的防盗门)
import "@openzeppelin/contracts/access/AccessControl.sol";   //导入“权限角色系统”——不只是一个主人，还可以设置不同的角色，比如某些人专门管理价格喂价。(像学校里除了校长，还有值日老师、图书管理员)
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";   //导入 ERC20 的“代币信息接口”;可以去问一个代币：“你有几位小数？”
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";   //导入 Chainlink 价格预言机接口——合约需要去问“价格机器人”：“抵押物现在值多少钱？”

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {   //在定义合约名字：SimpleStablecoin，同时继承四种能力(可以理解成这台“稳定币机器”天生会四种本领)
    using SafeERC20 for IERC20;   //让所有 IERC20 类型的代币，都可以使用 safeTransfer、safeTransferFrom 这些安全方法；“以后只要是这种代币，我们都用安全模式来操作。”

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");   //创建一个角色名字：PRICE_FEED_MANAGER_ROLE，表示“价格喂价管理员角色”；keccak256(...) 会把这串文字变成一个独特的“身份编号”
    IERC20 public immutable collateralToken;   //定义一个公开变量collateralToken：这个合约要接受哪一种代币当抵押物，就记在这里
    uint8 public immutable collateralDecimals;   //定义抵押代币的小数位数。(这个值会在一开始设好，以后不改)
    AggregatorV3Interface public priceFeed;   //定义一个价格预言机变量priceFeed：这里存着“价格机器人”的地址，合约以后就靠它查价格。
    uint256 public collateralizationRatio = 150; // 定义抵押率，以百分比表示（150 = 150%）。eg要借100远的话，得压150保证金

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);   //定义一个事件：铸造成功时记录；记录谁铸造了、铸造了多少稳定币、存了多少抵押物
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);   //定义赎回事件：当用户把稳定币换回抵押物时，记录这些信息
    event PriceFeedUpdated(address newPriceFeed);   //定义“价格喂价更新”事件：如果管理员换了新的价格机器人，就广播一下
    event CollateralizationRatioUpdated(uint256 newRatio);   //定义“抵押率更新”事件：如果管理员改了抵押率，就记录下来

    error InvalidCollateralTokenAddress();   //如果传进来的地址是空地址，就报“抵押代币地址无效”
    error InvalidPriceFeedAddress();   //错误：价格喂价地址无效
    error MintAmountIsZero();   //错误：铸造数量是 0
    error InsufficientStablecoinBalance();   //错误：稳定币余额不足
    error CollateralizationRatioTooLow();   //错误：抵押率太低

    constructor(   //初始化函数-初始化设置
        address _collateralToken,   //第一个输入参数：抵押代币地址
        address _initialOwner,    //第二个输入参数：初始管理员地址
        address _priceFeed   //第三个输入参数：价格预言机地址
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {   //1、调用ERC20 构造函数，把代币名字设成Simple USD Stablecoin；2、把代币符号设成sUSD；3、调用 Ownable，把主人设成 _initialOwner
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();   //如果抵押代币地址是空地址，就立刻报错
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();   //如果价格喂价地址是空地址，也报错

        collateralToken = IERC20(_collateralToken);   //把传进来的地址，当作 ERC20 代币来使用，并存进 collateralToken；即从现在起，合约知道“抵押物是哪种代币了”
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();   //去问这个抵押代币“你有几位小数？”然后保存下来
        priceFeed = AggregatorV3Interface(_priceFeed);   //把传进来的价格喂价地址保存起来，即系统知道该向哪个价格机器人问价了

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);   //把“默认管理员角色”给初始管理员(他是最高权限的人之一)
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);   //把“价格喂价管理员角色”也给初始管理员,就是说一开始同一个人既是总管理员，也是价格管理员
    }

    // 获取当前价格
    function getCurrentPrice() public view returns (uint256) {   //读取当前抵押物价格，view只看不改
        (, int256 price, , , ) = priceFeed.latestRoundData();   //从价格预言机里拿最新价格数据，这个函数会返回好几个值，这里只关心第二个值 price，其他先不管，所以用逗号跳过。类似从一张成绩单里，只拿“数学分数”，别的先不看
        require(price > 0, "Invalid price feed response");   //要求价格必须大于 0，否则报错""
        return uint256(price);
    }

    // 铸造稳定币(作用:用户存入抵押物，然后铸造稳定币)
    function mint(uint256 amount) external nonReentrant {   //定义一个外部函数：mint；nonReentrant 表示开启防重入保护
        if (amount == 0) revert MintAmountIsZero();   //如果想铸造 0 个，报错

        uint256 collateralPrice = getCurrentPrice();   //先取当前抵押物价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // “你要铸造这么多 sUSD，对应的美元价值是多少？”;假设 sUSD 为 18 位小数
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);   //需要的抵押物 = 稳定币价值 × 抵押率 ÷ 抵押物价格
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());   //进行“精度换算”(换算至同一单位)

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);   //从用户钱包，把需要的抵押物转到合约里
        _mint(msg.sender, amount);   //给用户铸造对应数量的 sUSD；相当于机器收到押金后，吐出新的稳定币

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);   //发出“铸造成功”的事件广播，记录：谁铸造了、铸造多少、存了多少抵押物
    }

    // 赎回抵押物(作用：用户把 sUSD 还回来，换回抵押物)
    function redeem(uint256 amount) external nonReentrant {   //定义赎回函数：redeem
        if (amount == 0) revert MintAmountIsZero();   //如果赎回数量是 0，报错
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();   //如果用户手里的 sUSD 不够，就报错

        uint256 collateralPrice = getCurrentPrice();   //读取当前抵押物价格
        uint256 stablecoinValueUSD = amount * (10 ** decimals());   //计算这些稳定币对应的美元价值
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);   //算应该退给用户多少抵押物：退回的抵押物 = 稳定币价值 ÷ 抵押率 ÷ 抵押物价格
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());   //再做一次精度换算，保证单位一致

        _burn(msg.sender, amount);   //把用户交回来的 sUSD 销毁(这些稳定币不再存在)，类似你把兑换券交回去，兑换券就作废
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);   //把算好的抵押物转回给用户

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);   //广播赎回成功事件
    }

    // 设置抵押率
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {   //定义一个只有主人能调用的函数：设置抵押率
        if (newRatio < 100) revert CollateralizationRatioTooLow();   //如果新抵押率小于 100，就报错
        collateralizationRatio = newRatio;   //把新的抵押率保存起来
        emit CollateralizationRatioUpdated(newRatio);   //广播“抵押率更新”事件
    }

    // 设置价格喂价合约
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {   //定义一个函数：修改价格预言机地址
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();   //如果新地址是空地址，就报错
        priceFeed = AggregatorV3Interface(_newPriceFeed);   //把新的价格喂价地址存起来
        emit PriceFeedUpdated(_newPriceFeed);   //广播“价格喂价更新”事件
    }

    // 预估铸造时需要多少抵押物(只读)
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {   //“如果我要铸造这么多 sUSD，需要先准备多少抵押物？”
        if (amount == 0) return 0;   //如果要铸造 0 个，那需要抵押物也是 0

        uint256 collateralPrice = getCurrentPrice();   //拿当前价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());   //算稳定币美元价值
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);   //按抵押率算需要多少抵押物
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());   //进行精度换算

        return adjustedRequiredCollateral;
    }

    // 预估赎回时能拿回多少抵押物(只读)
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {   //提前帮你算：“如果我要赎回这么多 sUSD，我大概能拿回多少抵押物？”
        if (amount == 0) return 0;   //如果赎回 0，那返回 0

        uint256 collateralPrice = getCurrentPrice();   //拿当前价格
        uint256 stablecoinValueUSD = amount * (10 ** decimals());   //算这些稳定币值多少钱
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);   //按公式计算要退多少抵押物
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());   //做精度换算

        return adjustedCollateralToReturn;
    }

}



// 该份合约主要完成：用户拿一种“抵押代币”放进合约，合约根据价格，计算你够不够资格铸造稳定币，如果够，就给你铸造 sUSD，你以后可以把 sUSD 烧掉，换回抵押物，合约主人还能改抵押率、改价格喂价地址
// keccak256(...) 会把这串文字变成一个独特的“身份编号”。可以理解成：给“价格管理员”发了一张专属工牌
// immutable 表示：这个值在构造函数里设定后，以后不能再改。像是机器安装好后，押金只能收某一种代币，不能随便换。
// Q:为什么叫稳定币? A:它想让 sUSD 尽量接近 1 美元的价值，不是靠“随便说我值 1 美元”，而是靠：有抵押物做担保、有价格预言机提供价格、有超额抵押保护系统安全
// 抵押物 collateral：就是你先交给系统保管的东西，像押金
// 稳定币 stablecoin：是系统发给你的代币，这里叫sUSD。
// 抵押率 collateralizationRatio,假设为 150%，想拿 100 美元的稳定币，得先押 150 美元的东西
// 价格预言机 price feed：就是给区块链合约“报价格”的机器人。因为合约自己不知道现实世界价格，所以要靠它告诉价格。
// 铸造 mint 和销毁 burn——mint：创建新币；burn：把币删除