// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleStablecoin - 简单抵押型稳定币合约
/// @notice 用户可以抵押 ERC20 代币铸造 sUSD，并按抵押比例赎回
/// @dev 使用 Chainlink 价格预言机获取抵押品价格，支持可升级的抵押率和价格预言机地址

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    // ------------------------------
    // 角色定义
    // ------------------------------
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");

    // ------------------------------
    // 状态变量
    // ------------------------------
    IERC20 public immutable collateralToken;           // 抵押代币（ERC20）
    uint8 public immutable collateralDecimals;         // 抵押代币小数位
    AggregatorV3Interface public priceFeed;           // Chainlink 价格预言机
    uint256 public collateralizationRatio = 150;      // 抵押率，百分比形式（150 = 150%）

    // ------------------------------
    // 事件定义
    // ------------------------------
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    event PriceFeedUpdated(address newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);

    // ------------------------------
    // 自定义错误
    // ------------------------------
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();

    // ------------------------------
    // 构造函数
    // ------------------------------
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

        // 授予初始管理员角色
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // ------------------------------
    // 内部和外部方法
    // ------------------------------

    /// @notice 获取当前抵押品价格（USD计价）
    /// @return 当前价格，单位与预言机一致
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    /// @notice 铸造稳定币
    /// @param amount 要铸造的 sUSD 数量（18位小数）
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice(); // 获取抵押品价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // sUSD 的价值
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);

        // 调整抵押品数量，考虑小数位差异
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 转移抵押品到合约
        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);

        // 铸造稳定币
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    /// @notice 赎回稳定币并返还抵押品
    /// @param amount 要赎回的 sUSD 数量
    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 销毁用户 sUSD
        _burn(msg.sender, amount);

        // 返还抵押品
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    /// @notice 设置新的抵押率
    /// @param newRatio 新抵押率（百分比）
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    /// @notice 更新价格预言机地址
    /// @param _newPriceFeed 新的 Chainlink 价格预言机
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    /// @notice 查看铸造指定数量稳定币所需抵押品
    /// @param amount sUSD 数量
    /// @return 所需抵押品数量
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    /// @notice 查看赎回指定数量稳定币可获得的抵押品
    /// @param amount sUSD 数量
    /// @return 可获得抵押品数量
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }
}
