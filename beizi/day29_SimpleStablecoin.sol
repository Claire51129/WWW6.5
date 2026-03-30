// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    
    IERC20 public immutable collateralToken;
    uint8 public immutable collateralDecimals;
    AggregatorV3Interface public priceFeed;
    uint256 public collateralizationRatio = 150; 

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    event PriceFeedUpdated(address newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);

    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) 
        ERC20("Simple USD Stablecoin", "sUSD") 
        Ownable(_initialOwner) // This is correct for OZ 5.0
    {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // solhint-disable-next-line not-rely-on-time
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 adjustedRequiredCollateral = getRequiredCollateralForMint(amount);

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 adjustedCollateralToReturn = getCollateralForRedeem(amount);

        _burn(msg.sender, amount);
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    // Logic separated for clarity and to avoid Stack Too Deep errors
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        uint256 collateralPrice = getCurrentPrice();
        uint256 priceFeedDecimals = priceFeed.decimals();
        
        // Calculation with precision handling:
        // (Amount * Ratio * PriceFeedPrecision) / (Price * 100)
        uint256 requiredCollateral = (amount * collateralizationRatio * (10 ** priceFeedDecimals)) / (collateralPrice * 100);
        
        // Adjust for collateral token decimals (e.g. WBTC is 8, USDC is 6)
        return (requiredCollateral * (10 ** collateralDecimals)) / (10 ** decimals());
    }

    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        uint256 collateralPrice = getCurrentPrice();
        uint256 priceFeedDecimals = priceFeed.decimals();

        // (Amount * 100 * PriceFeedPrecision) / (Ratio * Price)
        uint256 collateralToReturn = (amount * 100 * (10 ** priceFeedDecimals)) / (collateralizationRatio * collateralPrice);
        
        return (collateralToReturn * (10 ** collateralDecimals)) / (10 ** decimals());
    }

    // Admin functions
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    function setPriceFeedContract(address _newPriceFeed) external {
        _checkRole(PRICE_FEED_MANAGER_ROLE); // Manual check to be explicit
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }
    
    // Override supportsInterface for AccessControl
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
