// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    IERC20 public collateralToken;
    uint8 public collateralDecimals;
    AggregatorV3Interface public priceFeed;
    uint256 public collateralizationRatio;  
    event Minted(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event Redeemed(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event PriceFeedUpdated(address indexed newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();
    constructor(
        address _collateralToken,
        address _priceFeed,
        uint256 _collateralizationRatio
    ) ERC20("Simple USD", "sUSD") Ownable(msg.sender) {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        if (_collateralizationRatio < 10000) revert CollateralizationRatioTooLow();
        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);
        collateralizationRatio = _collateralizationRatio;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PRICE_FEED_MANAGER_ROLE, msg.sender);
    }
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        uint8 priceFeedDecimals = priceFeed.decimals();
        if (priceFeedDecimals < 18) {
            return uint256(price) * (10 ** (18 - priceFeedDecimals));
        } else if (priceFeedDecimals > 18) {
            return uint256(price) / (10 ** (priceFeedDecimals - 18));
        }
        return uint256(price);
    }
    function mint(uint256 stablecoinAmount) external nonReentrant {
        if (stablecoinAmount == 0) revert MintAmountIsZero();
        uint256 requiredCollateral = getRequiredCollateralForMint(stablecoinAmount);
        collateralToken.safeTransferFrom(msg.sender, address(this), requiredCollateral);
        _mint(msg.sender, stablecoinAmount);
        emit Minted(msg.sender, stablecoinAmount, requiredCollateral);
    }
    function redeem(uint256 stablecoinAmount) external nonReentrant {
        if (balanceOf(msg.sender) < stablecoinAmount) {
            revert InsufficientStablecoinBalance();
        }
        uint256 collateralToReturn = getCollateralForRedeem(stablecoinAmount);   
        _burn(msg.sender, stablecoinAmount);        
        collateralToken.safeTransfer(msg.sender, collateralToReturn);       
        emit Redeemed(msg.sender, stablecoinAmount, collateralToReturn);
    }
    function getRequiredCollateralForMint(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        uint256 baseCollateral = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;        
        uint256 requiredCollateral = (baseCollateral * collateralizationRatio) / 10000;
        return requiredCollateral;
    }
    function getCollateralForRedeem(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        uint256 collateralAmount = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;
        return collateralAmount;
    }
    function setCollateralizationRatio(uint256 _newRatio) external onlyOwner {
        if (_newRatio < 10000) revert CollateralizationRatioTooLow();
        collateralizationRatio = _newRatio;
        emit CollateralizationRatioUpdated(_newRatio);
    }
    function setPriceFeedContract(address _newPriceFeed)
        external
        onlyRole(PRICE_FEED_MANAGER_ROLE)
    {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }
    function getSystemInfo() external view returns (
        address _collateralToken,
        uint256 _collateralizationRatio,
        uint256 _currentPrice,
        uint256 _totalSupply,
        uint256 _collateralBalance
    ) {
        return (
            address(collateralToken),
            collateralizationRatio,
            getCurrentPrice(),
            totalSupply(),
            collateralToken.balanceOf(address(this))
        );
    }
}