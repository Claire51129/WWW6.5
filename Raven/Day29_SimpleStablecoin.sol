// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStableCoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
	// Use safe version of IERC20
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
	// Returns error selector instead of string to save gas
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();
	constructor(
		address _collateralToken,
		address _initialOwner,
		address _priceFeed
	) ERC20("Simple USD stablecoin", "sUSD") Ownable(_initialOwner) {
		if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
		if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
		collateralToken = IERC20(_collateralToken);
		collateralDecimals = IERC20Metadata(_collateralToken).decimals();
		priceFeed = AggregatorV3Interface(_priceFeed);
        // Access control functions
		_grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
	}
	function getCurrentPrice() public view returns (uint256) {
		(, int256 price, , , ) = priceFeed.latestRoundData();
		require(price > 0, "Invalid price");
		return uint256(price);
	}
	// User stakes collateral token and gets stable money
	function mint(uint256 amount) external nonReentrant {
		if (amount == 0) revert MintAmountIsZero();
		uint256 collateralPrice = getCurrentPrice();
		uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
		// Extra collatoral rate
		uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
		// Precision conversion
		uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());
		collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
		_mint(msg.sender, amount);
		emit Minted(msg.sender, amount, adjustedRequiredCollateral);
	}
	// Redeem collateral money after return stable token
	function redeem(uint256 amount) external nonReentrant {
		if (amount == 0) revert MintAmountIsZero();
		if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();
		uint256 collateralPrice = getCurrentPrice();
		uint256 stablecoinValueUSD = amount * (10 ** decimals());
		// Reduce collateral tokens when redeem
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