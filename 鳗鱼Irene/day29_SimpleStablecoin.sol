//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";//标准代币功能——铸造、转账和管理余额
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";//SafeERC20 是处理其他 ERC-20 代币的安全网
// 价格源管理器:特定账户可以在没有完全管理员控制的情况下更新价格源
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";//让我们的稳定币看到抵押代币的真实世界价格

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl 
{
    using SafeERC20 for IERC20;
    //谁可以更新价格源,一旦部署就永远不会改变,使用加密标识符
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    //存储用户必须作为抵押品存入的 ERC-20 代币的地址，immutable确保它只能设置一次
    IERC20 public immutable collateralToken;
    //抵押代币的小数部分
    uint8 public immutable collateralDecimals;
    // Chainlink 价格源，使用它在有人铸造或赎回稳定币时获取我们抵押代币的实时价格
    AggregatorV3Interface public priceFeed;
    //抵押率，用户在铸造稳定币时必须始终存入其价值的 150% 的抵押品
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%）

    //铸造
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    //赎回
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    //价格源地址已更新
    event PriceFeedUpdated(address newPriceFeed);
    //抵押率已更新
    event CollateralizationRatioUpdated(uint256 newRatio);

    //自定义错误，取代require() 语句
    error InvalidCollateralTokenAddress();//无效（零）抵押代币地址部署合约
    error InvalidPriceFeedAddress();//价格源地址无效
    error MintAmountIsZero();//试图铸造零稳定币
    error InsufficientStablecoinBalance();//试图赎回比他们实际余额更多的稳定币
    error CollateralizationRatioTooLow();//试图将抵押率设置为低于 100%

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
     ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        //设置名称和符号
        //地址有效
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        //保存抵押代币的地址
        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);

        //将合约连接到 Chainlink 价格源，使其能够按需获取实时价格数据
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    //从 Chainlink 获取实时价格
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();//最新报告的价格
        require(price > 0, "Invalid price feed response");//防止返回坏数据
        return uint256(price);
    }

    //铸造稳定币
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();//阻止用户铸造零稳定币

        uint256 collateralPrice = getCurrentPrice();//使用连接的 Chainlink 价格源获取抵押代币的当前实时价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); //计算用户想要铸造的稳定币的 USD 价值， 假设 sUSD 为 18 位小数
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);//计算用户需要存入多少抵押品价值
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());//调整数字以确保计算对于抵押代币和价格源都是精度正确的

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        _mint(msg.sender, amount);//将所需数量的抵押品从用户转入合约

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);//铸造请求数量的 sUSD 稳定币直接进入用户的钱包
    }

    //赎回稳定币
    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();//阻止零值赎回
        //检查用户实际拥有足够的 sUSD 来赎回
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        _burn(msg.sender, amount);//销毁正在赎回的稳定币
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);//计算的抵押品数量安全地发送回用户的钱包

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    //更新抵押率
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();//比率永远不能低于 100%
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    //更新价格源
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    //预览所需抵押品金额
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    //预览赎回时返回的抵押品数量
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }
}