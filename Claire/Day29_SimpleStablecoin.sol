// SPDX-License-Identifier: MIT
// 代码开源协议：MIT协议，大家可以随便用。

pragma solidity ^0.8.20;
// 这个合约需要用Solidity 0.8.20及以上版本编译。

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// 导入ERC20标准合约，这个稳定币本身就是一个ERC20代币。

import "@openzeppelin/contracts/access/Ownable.sol";
// 导入Ownable（所有者权限），用于管理员功能。

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 导入重入攻击防护。

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// 导入SafeERC20，安全的代币转账（检查返回值，防止某些代币不返回bool）。

import "@openzeppelin/contracts/access/AccessControl.sol";
// 导入AccessControl（访问控制），用于更细粒度的权限管理。

import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
// 导入ERC20元数据接口，用于获取代币的小数位数。

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// 导入Chainlink价格预言机接口，用于获取抵押品的实时价格。

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
// 定义一个合约叫"简单稳定币"，它继承了：
// - ERC20：稳定币本身是一个代币
// - Ownable：拥有所有者权限
// - ReentrancyGuard：防重入保护
// - AccessControl：细粒度权限控制

    using SafeERC20 for IERC20;
    // 使用SafeERC20库，为IERC20类型添加安全的转账方法。

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    // 定义价格预言机管理员的角色哈希。只有拥有此角色的人才能更新价格预言机地址。

    IERC20 public immutable collateralToken;
    // 抵押品代币（比如ETH、WBTC等）。immutable表示部署后不能改，节省gas。

    uint8 public immutable collateralDecimals;
    // 抵押品代币的小数位数（比如ETH是18位，USDC是6位）。immutable部署时确定。

    AggregatorV3Interface public priceFeed;
    // Chainlink价格预言机接口，用于获取抵押品/USD的实时价格。

    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%）
    // 抵押率，以百分比表示。150表示需要150%的抵押率。
    // 例如：要铸造100美元的sUSD，需要抵押150美元的ETH。

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    // 铸造事件：谁，铸造了多少稳定币，抵押了多少抵押品。

    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    // 赎回事件：谁，销毁了多少稳定币，取回了多少抵押品。

    event PriceFeedUpdated(address newPriceFeed);
    // 价格预言机更新事件：新的预言机地址。

    event CollateralizationRatioUpdated(uint256 newRatio);
    // 抵押率更新事件：新的抵押率。

    error InvalidCollateralTokenAddress();
    // 错误：无效的抵押品代币地址。

    error InvalidPriceFeedAddress();
    // 错误：无效的价格预言机地址。

    error MintAmountIsZero();
    // 错误：铸造数量为0。

    error InsufficientStablecoinBalance();
    // 错误：稳定币余额不足。

    error CollateralizationRatioTooLow();
    // 错误：抵押率太低（不能低于100%）。

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        // 构造函数，部署时运行。
        // 参数：抵押品代币地址、初始所有者地址、价格预言机地址。
        // 调用父类构造函数：ERC20设置代币名称"sUSD"，Ownable设置所有者。

        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        // 检查：抵押品代币地址不能为0地址。

        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        // 检查：价格预言机地址不能为0地址。

        collateralToken = IERC20(_collateralToken);
        // 设置抵押品代币地址。

        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        // 获取抵押品代币的小数位数并存储。

        priceFeed = AggregatorV3Interface(_priceFeed);
        // 设置价格预言机地址。

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        // 授予初始所有者管理员角色（最高权限）。

        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
        // 授予初始所有者价格预言机管理员角色。
    }

    function getCurrentPrice() public view returns (uint256) {
        // 获取当前抵押品价格（以美元计价，带8位小数）。
        // Chainlink价格通常有8位小数（比如1 ETH = 2000.00000000美元）。

        (, int256 price, , , ) = priceFeed.latestRoundData();
        // 调用Chainlink预言机获取最新价格。
        // 忽略其他返回值（roundId, startedAt, updatedAt, answeredInRound）。

        require(price > 0, "Invalid price feed response");
        // 检查：价格必须大于0。

        return uint256(price);
        // 返回价格（转换为uint256）。
    }

    function mint(uint256 amount) external nonReentrant {
        // 铸造稳定币函数。用户抵押抵押品，获得稳定币。
        // amount：要铸造的稳定币数量（单位：最小单位，比如1 sUSD = 10^18 wei）。

        if (amount == 0) revert MintAmountIsZero();
        // 检查：铸造数量不能为0。

        uint256 collateralPrice = getCurrentPrice();
        // 获取当前抵押品价格（比如1 ETH = 2000美元，返回2000 * 10^8）。

        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 假设 sUSD 为 18 位小数
        // 计算铸造amount个稳定币需要多少美元价值。
        // 例如：铸造100个sUSD（假设18位小数），需要100美元的抵押品价值。
        // amount是10^18的倍数，10**decimals()也是10^18，相乘后得到100 * 10^36，需要调整。

        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        // 计算需要多少抵押品（按原始单位，未调整小数位数）。
        // 公式：所需抵押品 = (稳定币价值 × 抵押率) ÷ (100 × 抵押品价格)
        // 例如：100美元 × 150% ÷ (100 × 2000) = 150 ÷ 200000 = 0.00075 ETH

        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());
        // 调整抵押品数量到正确的小数位数。
        // requiredCollateral是基于18位稳定币和8位价格计算的，需要转换成抵押品的实际小数位数。
        // 例如：0.00075 ETH（18位小数）需要转换成实际的wei单位。

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        // 从用户钱包转出调整后的抵押品数量到合约。

        _mint(msg.sender, amount);
        // 铸造amount个稳定币发给用户。

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
        // 发出铸造事件。
    }

    function redeem(uint256 amount) external nonReentrant {
        // 赎回稳定币函数。用户销毁稳定币，取回抵押品。

        if (amount == 0) revert MintAmountIsZero();
        // 检查：赎回数量不能为0。

        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();
        // 检查：用户有足够的稳定币余额。

        uint256 collateralPrice = getCurrentPrice();
        // 获取当前抵押品价格。

        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        // 计算amount个稳定币的美元价值。

        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        // 计算应该返回多少抵押品。
        // 公式：返回抵押品 = (稳定币价值 × 100) ÷ (抵押率 × 抵押品价格)
        // 注意：赎回时按当前抵押率计算，没有惩罚。

        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());
        // 调整抵押品数量到正确的小数位数。

        _burn(msg.sender, amount);
        // 销毁用户的amount个稳定币。

        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);
        // 把抵押品转回给用户。

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
        // 发出赎回事件。
    }

    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        // 设置新的抵押率。只有所有者能调用。

        if (newRatio < 100) revert CollateralizationRatioTooLow();
        // 检查：抵押率不能低于100%（防止资不抵债）。

        collateralizationRatio = newRatio;
        // 更新抵押率。

        emit CollateralizationRatioUpdated(newRatio);
        // 发出抵押率更新事件。
    }

    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        // 设置新的价格预言机地址。只有价格预言机管理员能调用。

        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        // 检查：新地址不能为0。

        priceFeed = AggregatorV3Interface(_newPriceFeed);
        // 更新预言机地址。

        emit PriceFeedUpdated(_newPriceFeed);
        // 发出预言机更新事件。
    }

    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        // 查看函数：铸造指定数量的稳定币需要多少抵押品。

        if (amount == 0) return 0;
        // 如果数量为0，返回0。

        uint256 collateralPrice = getCurrentPrice();
        // 获取当前价格。

        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        // 计算稳定币价值。

        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        // 计算所需抵押品。

        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());
        // 调整小数位数。

        return adjustedRequiredCollateral;
        // 返回调整后的抵押品数量。
    }

    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        // 查看函数：销毁指定数量的稳定币能取回多少抵押品。

        if (amount == 0) return 0;
        // 如果数量为0，返回0。

        uint256 collateralPrice = getCurrentPrice();
        // 获取当前价格。

        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        // 计算稳定币价值。

        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        // 计算应返回的抵押品。

        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());
        // 调整小数位数。

        return adjustedCollateralToReturn;
        // 返回调整后的抵押品数量。
    }
}
// 合约结束