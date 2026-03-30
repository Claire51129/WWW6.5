// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
/**
 * @title SimpleStablecoin
 * @notice 一个“简单版”的抵押稳定币示例合约：
 * - 使用某个 ERC20 作为抵押资产（`collateralToken`）
 * - 通过 Chainlink 价格预言机（`priceFeed`）获取抵押资产的 USD 价格
 * - 按给定的超额抵押率（`collateralizationRatio`，单位：%）铸造稳定币（`mint`）
 * - 稳定币销毁（`redeem`）后按比例返还抵押物
 *
 * 说明：本合约示例里对“单位精度/小数位”的处理做了简化假设，核心逻辑未做任何改动。
 */
contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    /// @dev 价格预言机管理角色：可以更新 `priceFeed`
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    IERC20 public immutable collateralToken;
    uint8 public immutable collateralDecimals;
    AggregatorV3Interface public priceFeed;

    /// @dev 超额抵押率（百分比表示），例如 150 表示 150%
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%）

    /// @dev 铸造事件：记录用户铸造数量与本次锁定的抵押量
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    /// @dev 赎回事件：记录用户赎回数量与本次返回的抵押量
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    /// @dev 更新价格预言机事件
    event PriceFeedUpdated(address newPriceFeed);
    /// @dev 更新抵押率事件
    event CollateralizationRatioUpdated(uint256 newRatio);

    /// @dev 输入校验/业务校验错误
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        // 抵押资产与价格预言机地址不能为零地址
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);
        // 抵押资产小数位，用于计算“返还/所需”的抵押数量（最小单位）
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);

        // AccessControl 初始化：owner 同时具备管理权限
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    /**
     * @notice 获取当前抵押资产的 USD 价格（带 priceFeed.decimals 的精度）
     * @return price 当前最新 round 的价格值（int256 转为 uint256）
     */
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // 链上价格必须为正，避免出现无效数据
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    /**
     * @notice 用抵押物铸造稳定币
     * @param amount 稳定币铸造数量（ERC20 最小单位）
     *
     * 核心步骤：
     * 1) 计算铸造 amount 所需的“USD 等值抵押”
     * 2) 根据抵押率换算为抵押资产数量（考虑 collateralDecimals 与 priceFeed.decimals）
     * 3) 从用户转入抵押资产，铸造稳定币给用户
     */
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice();
        // 假设 sUSD 使用 ERC20 默认 18 位小数（本合约未重写 decimals）
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 假设 sUSD 为 18 位小数
        // 根据超额抵押率计算抵押物 USD 等值需求，再将其换算为抵押代币最小单位
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    /**
     * @notice 赎回稳定币并返还抵押物
     * @param amount 要赎回销毁的稳定币数量（ERC20 最小单位）
     *
     * 核心步骤：
     * 1) 计算销毁 amount 对应应返还的抵押资产数量（考虑抵押率与价格）
     * 2) 先 burn 再转账返还抵押（更贴近“先改变账本状态”思路）
     */
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

    /// @notice 调整超额抵押率（owner 可调用）
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        // 简单示例限制：不能低于 100%（即至少不低于 1:1 抵押）
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    /// @notice 更新 Chainlink 价格预言机地址（由 PRICE_FEED_MANAGER_ROLE 调用）
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    /// @notice 查询铸造指定稳定币数量需要的抵押物数量（不转账，仅计算）
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    /// @notice 查询赎回指定稳定币数量可返还的抵押物数量（不转账，仅计算）
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }

}

