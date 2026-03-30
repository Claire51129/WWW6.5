// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    
    // 抵押代币
    IERC20 public immutable collateralToken;

    // 抵押代币的精度
    uint8 public immutable collateralDecimals;

    // 价格预言机
    AggregatorV3Interface public priceFeed;

    // 超额抵押率 150%
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%）

    // 铸造稳定币事件
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    // 赎回抵押物事件
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    // 价格更新提醒
    event PriceFeedUpdated(address newPriceFeed);
    // 超额抵押率更新事件
    event CollateralizationRatioUpdated(uint256 newRatio);

    // 无效的抵押代币地址
    error InvalidCollateralTokenAddress();
    // 无效的价格预言机地址
    error InvalidPriceFeedAddress();
    // 不能铸造0个稳定币
    error MintAmountIsZero();
    // 溢出
    error InsufficientStablecoinBalance();
    // 超额抵押率过低
    error CollateralizationRatioTooLow();

    // 稳定币为“sUSD”
    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // 通过价格预言机或者最新的价格
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    // 铸造稳定币
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 假设 sUSD 为 18 位小数
        // 如果想铸造amount个稳定币，需要提交的抵押代币数量：
        // 稳定币对应的价格 * 超额抵押率 / 抵押代币的价格*100
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        // 结合当前的价格预言机价格进行计算
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        _burn(msg.sender, amount);
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }

}

/**
statblecoin - 稳定币
key word： 稳定币、抵押、预言机、清算
抵押率计算、价格预言机、铸造赎回

稳定币目前主要有几种类型：
1）法币抵押型：USDC、USDT。 中心化托管、监管合规
2）加密抵押行：DAI。由ETH等加密资产抵押、去中心化、超额抵押
    它来源于 MakerDAO 创始人对中文“贷”字的音译。
-超额抵押：你解除的资产价值，必须低于你抵押的资产价值
    作用：低于价格波动、防止坏账
3）算法稳定币：通过算法调节供应量，无抵押或者部分抵押


** 超额抵押机制：
    抵押率 = 抵押品价值 ÷ 稳定币价值
        例如：存入价值$150的ETH，铸造$100的稳定币
        抵押率 = 150% = 1.5


** 价格预言机集成
    稳定币系统以来可靠的价格数据进行抵押品估值。
    但是也会有被恶意操纵的风险，还可能收到网络延迟的影响，单点故障的影响
    --》 多预言机聚合，时间加权平均

** 铸造与赎回机制
🔹 铸造流程
用户存入抵押品（如ETH）
系统获取当前价格
计算可铸造的稳定币数量
铸造稳定币给用户

🔹 赎回流程
用户销毁稳定币
系统计算应返还的抵押品
按1:1价值返还抵押品
更新用户余额
 */

 /**
 
 Q: 稳定币能用来干嘛？现有哪些应用场景？
    USDC能1:1兑换成真实的USD，所以真实的业务交易场景其实也都可以直接使用稳定币。

  */