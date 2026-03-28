// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// --- 直接在文件内定义接口，不再需要远程导入 ---
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    
    IERC20 public immutable collateralToken;
    uint8 public immutable collateralDecimals;
    AggregatorV3Interface public priceFeed;
    
    // 150% 的抵押率
    uint256 public collateralizationRatio = 150; 

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    event PriceFeedUpdated(address newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);

    // --- 错误定义 ---
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();
    error CalculationResultZero(); // 新增：防止计算结果为0

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);
        // 安全地获取 decimals
        collateralDecimals = _getDecimals(_collateralToken);
        priceFeed = AggregatorV3Interface(_priceFeed);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // 辅助函数：获取代币精度
    function _getDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("decimals()")
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        if (price <= 0) revert("Invalid price feed response");
        return uint256(price);
    }

    /**
     * @dev 铸造稳定币
     * 修复逻辑：调整计算顺序，避免整数除法归零
     */
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice();
        
        // --- 核心数学修复 ---
        // 目标：计算需要多少抵押品代币（包含其自身精度）
        // 公式：(稳定币金额 * 抵押率 * 抵押品精度) / (100 * 预言机价格 * 稳定币精度)
        
        uint256 numerator = amount * collateralizationRatio * (10 ** collateralDecimals);
        uint256 denominator = 100 * collateralPrice * (10 ** decimals());

        uint256 requiredCollateral = numerator / denominator;

        if (requiredCollateral == 0) revert CalculationResultZero();

        // 转移抵押品
        collateralToken.safeTransferFrom(msg.sender, address(this), requiredCollateral);
        
        // 铸造
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, requiredCollateral);
    }

    /**
     * @dev 赎回抵押品
     * 修复逻辑：同上
     */
    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 collateralPrice = getCurrentPrice();

        // --- 核心数学修复 ---
        // 公式：(稳定币金额 * 100 * 抵押品精度) / (抵押率 * 预言机价格 * 稳定币精度)
        
        uint256 numerator = amount * 100 * (10 ** collateralDecimals);
        uint256 denominator = collateralizationRatio * collateralPrice * (10 ** decimals());

        uint256 collateralToReturn = numerator / denominator;

        // 销毁稳定币
        _burn(msg.sender, amount);
        
        // 转移抵押品给用户
        collateralToken.safeTransfer(msg.sender, collateralToReturn);

        emit Redeemed(msg.sender, amount, collateralToReturn);
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

    // --- 视图函数 (已同步修复计算逻辑) ---

    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        
        uint256 numerator = amount * collateralizationRatio * (10 ** collateralDecimals);
        uint256 denominator = 100 * collateralPrice * (10 ** decimals());

        return numerator / denominator;
    }

    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        
        uint256 numerator = amount * 100 * (10 ** collateralDecimals);
        uint256 denominator = collateralizationRatio * collateralPrice * (10 ** decimals());

        return numerator / denominator;
    }
}