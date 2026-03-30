// SPDX-License-Identifier: MIT                             
pragma solidity ^0.8.20;                                        

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";         // 引入标准代币功能
import "@openzeppelin/contracts/access/Ownable.sol";            // 引入管理员权限
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";     // 引入安全锁
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // 安全转账工具
import "@openzeppelin/contracts/access/AccessControl.sol";      // 角色权限管理
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol"; // 获取代币小数位
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // 预言机价格

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl { // 稳定币合约
    using SafeERC20 for IERC20;                                   // 使用安全转账

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE"); // 价格管理员权限
    IERC20 public immutable collateralToken;                     // 抵押代币（用来抵押的钱）
    uint8 public immutable collateralDecimals;                   // 抵押代币小数位
    AggregatorV3Interface public priceFeed;                      // 预言机价格合约
    uint256 public collateralizationRatio = 150;                // 抵押率 150%（安全系数）

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited); // 发行稳定币
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned); // 赎回抵押品
    event PriceFeedUpdated(address newPriceFeed);               // 更新价格合约
    event CollateralizationRatioUpdated(uint256 newRatio);      // 更新抵押率

    error InvalidCollateralTokenAddress();                      // 错误：抵押代币地址无效
    error InvalidPriceFeedAddress();                            // 错误：价格地址无效
    error MintAmountIsZero();                                   // 错误：数量不能为0
    error InsufficientStablecoinBalance();                      // 错误：稳定币余额不足
    error CollateralizationRatioTooLow();                       // 错误：抵押率太低

    constructor(                                                  // 部署合约时初始化
        address _collateralToken,                                // 抵押代币地址
        address _initialOwner,                                   // 管理员地址
        address _priceFeed                                       // 价格预言机地址
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) { // 代币名称sUSD
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress(); // 地址不能为空
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress(); // 地址不能为空

        collateralToken = IERC20(_collateralToken);             // 设置抵押代币
        collateralDecimals = IERC20Metadata(_collateralToken).decimals(); // 获取抵押代币小数位
        priceFeed = AggregatorV3Interface(_priceFeed);          // 设置价格合约

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);           // 给管理员权限
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);     // 给价格管理权限
    }

    function getCurrentPrice() public view returns (uint256) {  // 获取当前抵押币价格
        (, int256 price, , , ) = priceFeed.latestRoundData();   // 从预言机拿价格
        require(price > 0, "Invalid price feed response");     // 价格必须合法
        return uint256(price);                                 // 返回价格
    }

    function mint(uint256 amount) external nonReentrant {       // 铸造（发行）稳定币
        if (amount == 0) revert MintAmountIsZero();             // 不能发行0个

        uint256 collateralPrice = getCurrentPrice();            // 获取抵押币价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 要发行的美元价值
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice); // 计算需要抵押多少
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals()); // 换算小数位

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral); // 收用户抵押品
        _mint(msg.sender, amount);                                 // 给用户发行稳定币

        emit Minted(msg.sender, amount, adjustedRequiredCollateral); // 记录发行事件
    }

    function redeem(uint256 amount) external nonReentrant {      // 赎回（销毁稳定币，拿回抵押品）
        if (amount == 0) revert MintAmountIsZero();             // 不能销毁0个
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance(); // 余额要足够

        uint256 collateralPrice = getCurrentPrice();            // 获取抵押币价格
        uint256 stablecoinValueUSD = amount * (10 ** decimals()); // 销毁的美元价值
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice); // 计算可赎回抵押品
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals()); // 换算小数位

        _burn(msg.sender, amount);                                 // 销毁稳定币
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn); // 退回抵押品

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn); // 记录赎回
    }

    function setCollateralizationRatio(uint256 newRatio) external onlyOwner { // 管理员修改抵押率
        if (newRatio < 100) revert CollateralizationRatioTooLow(); // 不能低于100%
        collateralizationRatio = newRatio;                        // 更新抵押率
        emit CollateralizationRatioUpdated(newRatio);             // 记录更新
    }

    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) { // 修改价格合约
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress(); // 地址不能为空
        priceFeed = AggregatorV3Interface(_newPriceFeed);              // 更新价格合约
        emit PriceFeedUpdated(_newPriceFeed);                         // 记录更新
    }

    // 函数：查询 铸造稳定币 需要抵押多少代币
function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) { // 查询发行需要多少抵押
    if (amount == 0) return 0; // 如果输入数量是0，直接返回0，不用计算

    uint256 collateralPrice = getCurrentPrice(); // 获取抵押品当前的美元价格
    uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 算出要铸的稳定币值多少美元
    uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice); // 算出需要多少抵押品（未调整小数位）
    uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals()); // 调整小数位，得到真实需要抵押数量

    return adjustedRequiredCollateral; // 返回最终需要抵押的代币数量
}

    // 函数：查询 销毁稳定币 能拿回多少抵押品
function getCollateralForRedeem(uint256 amount) public view returns (uint256) { // 查询销毁能拿回多少抵押
    if (amount == 0) return 0; // 如果输入数量是0，直接返回0

    uint256 collateralPrice = getCurrentPrice(); // 获取抵押品当前价格
    uint256 stablecoinValueUSD = amount * (10 ** decimals()); // 算出要销毁的稳定币值多少美元
    uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice); // 算出能退回多少抵押品（未调小数）
    uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals()); // 调整小数位，得到真实可退回数量

    return adjustedCollateralToReturn; // 返回最终能拿回的抵押品数量
}

}
//这是一个 1:1 锚定美元的稳定币（sUSD）
//您抵押加密货币 → 系统给您发行稳定币
//必须抵押 150% 价值，保证绝对安全
//销毁稳定币 → 拿回您的抵押品