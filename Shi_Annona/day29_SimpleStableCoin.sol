// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//提供了所有标准代币功能——铸造、转账和管理余额——无需从头开始编写
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//修饰符和防重入攻击
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//SafeERC20 是处理其他 ERC-20 代币的安全网。有时，代币合约表现不佳（如在没有错误的情况下转账失败），而 SafeERC20 确保所有代币操作要么成功完成，要么干净地失败。   
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//它允许合约定义自定义角色。在这个稳定币中，我们有一个特殊的 价格源管理器 角色——所以特定账户可以在没有完全管理员控制的情况下更新价格源。
import "@openzeppelin/contracts/access/AccessControl.sol";
//帮助我们获取关于抵押代币的额外信息，如它使用多少位小数。不同的代币有不同的小数设置，我们的数学需要考虑到这一点。
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
//从 Chainlink 导入 **AggregatorV3Interface**。这是让我们的稳定币**看到抵押代币的真实世界价格**的东西
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    //给所有参与进来的ERC代币都加上安全回滚的功能
    using SafeERC20 for IERC20;
    //身份管理卡，它控制谁可以更新价格源，为什么是“常量”？constant 意味着这个值一旦部署就永远不会改变。它被永久硬编码到合约中， gas 上更便宜、更安全，没有人有机会意外地（或恶意地）稍后修改角色标识符
    //bytes32这是一个标准化格式，使角色检查在以太坊虚拟机（EVM）内部快速高效
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    //这里存储用户质押代币的合约地址，设置为immutable因为要它不可更改
    IERC20 public immutable collateralToken;
    //不同的 ERC-20 代币可以有不同数量的小数（例如，USDC 使用 6，ETH 使用 18）。
    //我们在合约部署时将抵押代币的小数存储在这里，这样以后的铸造和赎回计算就保持准确。
    uint8 public immutable collateralDecimals;
    //这是一个指针？指向 Chainlink 价格源 合约
    AggregatorV3Interface public priceFeed;
    //抵押比率
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%）
    //铸造稳定币，谁，铸造了多少，质押了多少
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    //销毁稳定比，赎回自己的代币
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    //价格跟新
    event PriceFeedUpdated(address newPriceFeed);
    //质押比例更新
    event CollateralizationRatioUpdated(uint256 newRatio);
    //自定义错误它们更便宜、更易于阅读
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
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        //质押代币地址
        collateralToken = IERC20(_collateralToken);
        //质押代币的小数位
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        //预言机获得的价格
        priceFeed = AggregatorV3Interface(_priceFeed);
        //合约所有者为管理员，可以更新价格来源
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    function getCurrentPrice() public view returns (uint256) {
        //priceFeed是AggregatorV3Interface的接口指针。类似IERC20，可以把它想象成是一个可以与外界沟通的小机器人
        //roundId（这一轮数据的编号）answer（这就是我们真正想要的价格！）startedAt（这一轮数据是什么时候开始的）updatedAt（这一轮数据是什么时候最后更新的）answeredInRound（一个比较老的编号，现在基本不用了）
        //我们这个合约要准备“盒子”接收机器人带回来的信息，不要的信息就空着不给盒子
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        //使用连接的 Chainlink 价格源获取抵押代币的当前实时价格,这个是根据priceFeed在构造函数中得到的地址决定的
        //1 个 collateral 代币，现在值多少钱（以美元计价）
        uint256 collateralPrice = getCurrentPrice();
        //decimals从哪里来的，从import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol"，这里返回的是我这个合约的代币小数点，默认18，除非重写
        //意思是用户要本合约的代币乘以10的18次方，得到最好处理的证书，这里的单位是美元USD？放大用户的数字后面好处理
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 假设 sUSD 为 18 位小数
        //用户需要提供的抵押物
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        //* (10 ** collateralDecimals) → 把数量“放大”到代币的最小单位（像从公斤变成克）
        // / (10 ** priceFeed.decimals()) → 把价格带来的小数位“缩小”回去，让结果匹配代币的精度
        //对齐小数点
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();
        //同铸造代币的转换步骤
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
    //得到抵押品的量
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }
    //得到取回量
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }

}

