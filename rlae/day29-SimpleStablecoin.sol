// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //Ownable 介入引入一个简单的所有权系统
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; //导入 ReentrancyGuard，以保护像 mint 和 redeem 这样的重要函数免受一种称为"重入"的攻击，在这种攻击中，恶意合约试图在第一次调用完成之前重复调用函数
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //SafeERC20 是处理其他 ERC-20 代币的安全网
import "@openzeppelin/contracts/access/AccessControl.sol"; //它允许合约定义自定义角色。在这个稳定币中，我们有一个特殊的 价格源管理器 角色——所以特定账户可以在没有完全管理员控制的情况下更新价格源
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";//取关于抵押代币的额外信息，如它使用多少位小数
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; //让我们的稳定币看到抵押代币的真实世界价格的东西

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20; //交互的所有 IERC20 代币激活 SafeERC20
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    //bytes32 被使用是因为 AccessControl 中的角色标识符总是期望正好 32 字节——这是一个标准化格式，使角色检查在以太坊虚拟机（EVM）内部快速高效
    //PRICE_FEED_MANAGER_ROLE 的特殊角色，它控制谁可以更新价格源 constant 意味着这个值一旦部署就永远不会改变
    //我们使用 keccak256("PRICE_FEED_MANAGER_ROLE") 生成它，这样角色就有一个独特的、加密强度的标识符
    IERC20 public immutable collateralToken; //作为抵押品存入的 ERC-20 代币的地址,immutable 确保它只能设置一次 during deploy
    uint8 public immutable collateralDecimals; //将抵押代币的小数存储在这里
    AggregatorV3Interface public priceFeed; // Chainlink 价格源 合约 在有人铸造或赎回稳定币时获取抵押代币的实时价格
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%） 抵押率——意味着用户在铸造稳定币时必须始终存入其价值的 150% 的抵押品

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited); //当有人成功铸造新稳定币时，就会触发此事件
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned); //当有人将稳定币赎回为抵押品时
    event PriceFeedUpdated(address newPriceFeed); //表示价格源地址已更新
    event CollateralizationRatioUpdated(uint256 newRatio); //每当抵押率被更改时
    //自定义错误 省钱/省空间：它不存储冗长的字符串，而是通过四个字节的“选择器”来识别错误，可传参：你可以把动态数据（比如实际余额和所需余额）传给错误对象，方便调试
    //缺点：在一些旧的工具链或前端库中，解析自定义错误可能比简单的字符串稍微麻烦一点
    error InvalidCollateralTokenAddress(); //如果有人试图用无效（零）抵押代币地址部署合约
    error InvalidPriceFeedAddress(); //如果提供的价格源地址无效
    error MintAmountIsZero(); //如果用户试图铸造零稳定币
    error InsufficientStablecoinBalance(); //当用户试图赎回比他们实际余额更多的稳定币时
    error CollateralizationRatioTooLow(); //如果有人试图将抵押率设置为低于 100%
    constructor(
    address _collateralToken, //抵押代币的地址（像 USDC、WETH 等 ERC-20）
    address _initialOwner, //初始所有者的地址（管理员
    address _priceFeed //hainlink 价格源的地址（获取实时抵押品价格）
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
    //给我们的代币一个名称（"Simple USD Stablecoin"）和一个符号（"sUSD"），它们将出现在钱包和浏览器中
    if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
    if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

    collateralToken = IERC20(_collateralToken); //保存抵押代币的地址
    collateralDecimals = IERC20Metadata(_collateralToken).decimals(); //获取并存储抵押代币的小数
    priceFeed = AggregatorV3Interface(_priceFeed); //按需获取实时价格数据

    _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner); //让所有者完全控制合约的角色系统
    _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner); //让所有者在将来需要时更新价格源
    }

    function getCurrentPrice() public view returns (uint256) {
    //—任何人都可以调用它来获取最新价格，并且它不会改变任何状态
    (, int256 price, , , ) = priceFeed.latestRoundData();//这给我们最新报告的价格——但我们只关心元组中的第二个值，这是实际价格（作为 int256 返回）
    require(price > 0, "Invalid price feed response"); //安全起见，我们检查返回的价格大于零
    return uint256(price);
    }

    function mint(uint256 amount) external nonReentrant {
    if (amount == 0) revert MintAmountIsZero(); //阻止用户铸造零稳定币

    uint256 collateralPrice = getCurrentPrice(); //使用连接的 Chainlink 价格源获取抵押代币的当前实时价格
    uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 假设 sUSD 为 18 位小数
    uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice); //根据抵押率（如 150%）计算用户需要存入多少抵押品价值（以 USD 计
    uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals()); 
    //修正价格精度（Price Feed Decimals）与代币精度（Token Decimals）之间的差异，确保计算出的代币数量是正确的

    collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
    _mint(msg.sender, amount); //一旦抵押品安全存入，我们铸造请求数量的 sUSD 稳定币直接进入用户的钱包

    emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }
    //赎回是他们销毁他们的 sUSD 并取回他们的抵押品的方式
    function redeem(uint256 amount) external nonReentrant {
    if (amount == 0) revert MintAmountIsZero(); //阻止零值赎回
    if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance(); //检查用户实际拥有足够的 sUSD 来赎回

    uint256 collateralPrice = getCurrentPrice(); //从 Chainlink 获取抵押代币的最新真实世界价格
    uint256 stablecoinValueUSD = amount * (10 ** decimals()); //计算正在赎回的 sUSD 代币的 USD 价值，使用 18 位小数正确缩放
    uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice); //应该返回多少抵押品价值
    uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());//调整抵押代币使用的小数

    _burn(msg.sender, amount); //销毁正在赎回的稳定币
    collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn); //计算的抵押品数量安全地发送回用户的钱包

    emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }
    //更新抵押率 仅限所有者的函数
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
    if (newRatio < 100) revert CollateralizationRatioTooLow(); //比率永远不能低于 100% 确保每个稳定币始终至少由其全部价值的抵押品支持
    collateralizationRatio = newRatio;
    emit CollateralizationRatioUpdated(newRatio);
    }

    //更新价格源 函数只能由拥有 PRICE_FEED_MANAGER_ROLE 的人调用
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
    if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
    priceFeed = AggregatorV3Interface(_newPriceFeed);
    emit PriceFeedUpdated(_newPriceFeed);
    }
    //预览所需抵押品
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
    if (amount == 0) return 0;

    uint256 collateralPrice = getCurrentPrice(); //当前市场价格
    uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); //将稳定币的数量缩放到 18 位小数以用完整的 USD 价值术语表达它
    uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
    uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

    return adjustedRequiredCollateral;
    }
    //预览赎回时返回的抵押品
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
    if (amount == 0) return 0;

    uint256 collateralPrice = getCurrentPrice();
    uint256 stablecoinValueUSD = amount * (10 ** decimals());
    uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice); //抵押品的 USD 价值
    uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

    return adjustedCollateralToReturn; //返回用户如果赎回给定 sUSD 数量将收到的抵押品数量（以最小单位如 wei）
    }


}