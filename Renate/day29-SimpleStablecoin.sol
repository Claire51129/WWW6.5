// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ==================== Mock Chainlink 预言机 ====================

/// @title Mock Chainlink 价格预言机
/// @dev 模拟 Chainlink AggregatorV3Interface
/// @dev 用于本地测试，管理员可以手动设置价格
contract MockPriceFeed {
    /// @notice 价格数据结构
    struct RoundData {
        uint80 roundId;         // 轮次 ID
        int256 answer;          // 价格答案
        uint256 startedAt;      // 开始时间
        uint256 updatedAt;      // 更新时间
        uint80 answeredInRound; // 回答的轮次
    }
    
    /// @notice 当前价格数据
    /// @dev 使用 _data 后缀避免与函数名冲突
    RoundData public latestRoundDataStored;
    
    /// @notice 价格小数位数（Chainlink 标准是 8 位）
    uint8 public decimals = 8;
    
    /// @notice 预言机管理员
    address public admin;
    
    /// @notice 构造函数，设置初始价格
    /// @param _initialPrice 初始价格（8 位小数）
    constructor(int256 _initialPrice) {
        admin = msg.sender;
        updatePrice(_initialPrice);
    }
    
    /// @notice 更新价格（仅管理员）
    /// @param _price 新价格（8 位小数）
    function updatePrice(int256 _price) public {
        require(msg.sender == admin, "Only admin");
        latestRoundDataStored = RoundData({
            roundId: latestRoundDataStored.roundId + 1,
            answer: _price,
            startedAt: block.timestamp,
            updatedAt: block.timestamp,
            answeredInRound: latestRoundDataStored.roundId + 1
        });
    }
    
    /// @notice 获取最新价格数据（符合 Chainlink 接口）
    /// @return roundId 轮次 ID
    /// @return answer 价格
    /// @return startedAt 开始时间
    /// @return updatedAt 更新时间
    /// @return answeredInRound 回答的轮次
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (
            latestRoundDataStored.roundId,
            latestRoundDataStored.answer,
            latestRoundDataStored.startedAt,
            latestRoundDataStored.updatedAt,
            latestRoundDataStored.answeredInRound
        );
    }
}

/// @title Chainlink 聚合器接口
/// @dev 标准 Chainlink 价格预言机接口
/// @dev 用于与真实 Chainlink 预言机交互
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// ==================== 稳定币合约 ====================

/// @title 简单稳定币合约
/// @title Simple Stablecoin
/// @dev 一个超额抵押的稳定币系统，以 ETH 作为抵押品
/// @dev 抵押率要求 150%，即每铸造 1 美元稳定币需要 1.5 美元 ETH 抵押
/// @dev 继承 ERC20（稳定币本身）、ReentrancyGuard（防重入）、Ownable（管理权限）
contract SimpleStablecoin is ERC20, ReentrancyGuard, Ownable {
    
    // ==================== 状态变量 ====================
    
    /// @notice ETH/USD 价格预言机
    /// @dev 使用 Chainlink 预言机获取 ETH 实时价格
    AggregatorV3Interface internal priceFeed;

    /// @notice 抵押率要求（百分比）
    /// @dev 150 表示 150% 抵押率
    /// @dev 这意味着每铸造 100 美元的稳定币，需要 150 美元的 ETH 抵押
    uint256 public constant COLLATERAL_RATIO = 150;
    
    /// @notice 清算奖励比例
    /// @dev 5 表示 5% 的奖励给清算人
    uint256 public constant LIQUIDATION_BONUS = 5;

    /// @notice 用户抵押品映射
    /// @dev 用户地址 => 抵押的 ETH 数量（wei）
    mapping(address => uint256) public collateralDeposited;

    // ==================== 事件 ====================
    
    /// @notice 存入抵押品事件
    /// @param user 用户地址
    /// @param amount 存入的 ETH 数量
    event CollateralDeposited(address indexed user, uint256 amount);
    
    /// @notice 铸造稳定币事件
    /// @param user 用户地址
    /// @param amount 铸造的稳定币数量
    event StablecoinMinted(address indexed user, uint256 amount);
    
    /// @notice 销毁稳定币事件
    /// @param user 用户地址
    /// @param amount 销毁的稳定币数量
    event StablecoinBurned(address indexed user, uint256 amount);
    
    /// @notice 提取抵押品事件
    /// @param user 用户地址
    /// @param amount 提取的 ETH 数量
    event CollateralWithdrawn(address indexed user, uint256 amount);
    
    /// @notice 清算事件
    /// @param liquidator 清算人地址
    /// @param user 被清算的用户地址
    /// @param debtPaid 偿还的债务金额
    /// @param collateralSeized 获得的抵押品数量
    event Liquidation(
        address indexed liquidator,
        address indexed user,
        uint256 debtPaid,
        uint256 collateralSeized
    );

    // ==================== 构造函数 ====================
    
    /// @notice 创建稳定币合约
    /// @param _priceFeedAddress 价格预言机地址
    /// @dev 初始化 ERC20 代币，名称为 "StableUSD"，符号为 "SUSD"
    constructor(address _priceFeedAddress) 
        ERC20("StableUSD", "SUSD") 
        Ownable(msg.sender) 
    {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    // ==================== 核心功能 ====================
    
    /// @notice 存入 ETH 作为抵押品
    /// @dev 用户发送 ETH 到合约，增加其抵押品余额
    function depositCollateral() external payable {
        // 检查存入金额大于 0
        require(msg.value > 0, "Must deposit some ETH");
        
        // 增加用户的抵押品记录
        collateralDeposited[msg.sender] += msg.value;
        
        // 触发存入事件
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /// @notice 铸造稳定币
    /// @param amountToMint 要铸造的稳定币数量
    /// @dev 用户必须有足够的抵押品才能铸造
    /// @dev 使用 nonReentrant 防止重入攻击
    function mintStablecoin(uint256 amountToMint) external nonReentrant {
        // 计算用户当前抵押品的美元价值
        uint256 currentEthValue = getCollateralValueInUsd(msg.sender);
        
        // 获取用户当前的债务（已铸造的稳定币）
        uint256 currentDebt = balanceOf(msg.sender);
        
        // 计算最大可铸造金额
        // 公式：最大可铸造 = 抵押品价值 * 100 / 抵押率
        // 例如：$150 抵押品，150% 抵押率，最大可铸造 = 150 * 100 / 150 = $100
        uint256 maxMintable = (currentEthValue * 100) / COLLATERAL_RATIO;
        
        // 检查铸造后不会超过最大可铸造金额
        require(currentDebt + amountToMint <= maxMintable, "Not enough collateral!");

        // 铸造稳定币给用户
        _mint(msg.sender, amountToMint);
        
        // 触发铸造事件
        emit StablecoinMinted(msg.sender, amountToMint);
    }

    /// @notice 销毁稳定币
    /// @param amountToBurn 要销毁的稳定币数量
    /// @dev 用户销毁自己的稳定币，减少债务
    function burnStablecoin(uint256 amountToBurn) external nonReentrant {
        // 销毁用户的稳定币
        _burn(msg.sender, amountToBurn);
        
        // 触发销毁事件
        emit StablecoinBurned(msg.sender, amountToBurn);
    }

    /// @notice 提取抵押品
    /// @param amount 要提取的 ETH 数量
    /// @dev 提取后必须保持足够的抵押率
    function withdrawCollateral(uint256 amount) external nonReentrant {
        // 获取用户当前债务
        uint256 currentDebt = balanceOf(msg.sender);
        
        // 计算提取后的剩余抵押品
        uint256 remainingCollateral = collateralDeposited[msg.sender] - amount;
        
        // 计算剩余抵押品的美元价值
        uint256 remainingValue = (remainingCollateral * getEthPrice()) / 1e18;
        
        // 计算所需的最低抵押品价值
        // 公式：所需价值 = 债务 * 抵押率 / 100
        uint256 requiredCollateralValue = (currentDebt * COLLATERAL_RATIO) / 100;

        // 检查提取后仍有足够的抵押品
        require(remainingValue >= requiredCollateralValue, "Cannot withdraw, health factor too low");

        // 减少用户的抵押品记录
        collateralDeposited[msg.sender] -= amount;
        
        // 将 ETH 转给用户
        // 使用 call 替代已弃用的 transfer
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "ETH transfer failed");
        
        // 触发提取事件
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ==================== 清算功能 ====================
    
    /// @notice 清算不健康的头寸
    /// @param user 要清算的用户地址
    /// @dev 当用户的抵押率低于 150% 时，任何人都可以清算
    /// @dev 清算人支付债务，获得抵押品 + 奖励
    function liquidate(address user) external nonReentrant {
        // 获取用户的抵押品价值
        uint256 collateralValue = getCollateralValueInUsd(user);
        
        // 获取用户的债务
        uint256 debtValue = balanceOf(user);
        
        // 如果没有债务，直接返回
        if (debtValue == 0) return;

        // 计算健康因子（抵押率）
        // 公式：健康因子 = 抵押品价值 * 100 / 债务
        uint256 healthFactor = (collateralValue * 100) / debtValue;
        
        // 检查头寸不健康（低于 150% 抵押率）
        require(healthFactor < COLLATERAL_RATIO, "Position is healthy");
        
        // 清算人销毁稳定币来偿还用户的债务
        _burn(msg.sender, debtValue);
        
        // 获取用户的全部抵押品
        uint256 collateralToTransfer = collateralDeposited[user];
        
        // 清空用户的抵押品记录
        collateralDeposited[user] = 0;
        
        // 将抵押品 + 奖励转给清算人
        // 清算人获得用户的全部抵押品 + 5% 奖励
        // 计算公式：抵押品 + (抵押品 * 5 / 100) = 抵押品 * 105 / 100
        (bool sent, ) = payable(msg.sender).call{value: collateralToTransfer * (100 + LIQUIDATION_BONUS) / 100}("");
        require(sent, "Collateral transfer failed");
        
        // 触发清算事件
        emit Liquidation(msg.sender, user, debtValue, collateralToTransfer);
    }

    // ==================== 价格预言机功能 ====================
    
    /// @notice 获取 ETH 当前价格
    /// @return ETH 价格（18 位小数）
    /// @dev 从 Chainlink 预言机获取价格，并转换为 18 位小数
    function getEthPrice() public view returns (uint256) {
        // 从预言机获取最新价格数据
        (, int256 price, , , ) = priceFeed.latestRoundData();
        
        // 如果价格为负数，返回 0
        if (price < 0) return 0;
        
        // Chainlink 返回的价格是 8 位小数
        // 我们需要转换为 18 位小数，所以乘以 1e10
        // 例如：Chainlink 返回 2000_00000000（$2000，8位小数）
        // 转换后：2000_00000000 * 1e10 = 2000_000000000000000000（18位小数）
        return uint256(price) * 1e10;
    }

    /// @notice 获取用户抵押品的美元价值
    /// @param user 用户地址
    /// @return 抵押品价值（美元，18 位小数）
    function getCollateralValueInUsd(address user) public view returns (uint256) {
        // 获取用户的 ETH 抵押数量
        uint256 ethAmount = collateralDeposited[user];
        
        // 获取 ETH 当前价格
        uint256 ethPrice = getEthPrice();
        
        // 计算美元价值
        // 公式：(ETH 数量 * ETH 价格) / 1e18
        // 需要除以 1e18 是因为 ethPrice 是 18 位小数
        return (ethAmount * ethPrice) / 1e18;
    }
    
    /// @notice 获取用户的健康因子
    /// @param user 用户地址
    /// @return 健康因子（百分比）
    function getHealthFactor(address user) external view returns (uint256) {
        uint256 collateralValue = getCollateralValueInUsd(user);
        uint256 debtValue = balanceOf(user);
        
        if (debtValue == 0) return type(uint256).max; // 无债务时返回最大值
        
        return (collateralValue * 100) / debtValue;
    }
    
    /// @notice 获取最大可铸造金额
    /// @param user 用户地址
    /// @return 最大可铸造的稳定币数量
    function getMaxMintable(address user) external view returns (uint256) {
        uint256 collateralValue = getCollateralValueInUsd(user);
        return (collateralValue * 100) / COLLATERAL_RATIO;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 稳定币系统核心概念:
//    - 超额抵押: 抵押品价值 > 铸造的稳定币价值
//    - 抵押率: 抵押品价值 / 债务价值（本合约要求 150%）
//    - 健康因子: 衡量头寸安全性的指标
//    - 清算: 当抵押率不足时，第三方可以清算头寸
//
// 2. 数学原理:
//    抵押率 = 抵押品价值 / 债务价值 * 100%
//    
//    最大可铸造 = 抵押品价值 * 100 / 抵押率
//    
//    示例:
//    - ETH 价格 = $2000
//    - 存入 1 ETH = $2000
//    - 150% 抵押率
//    - 最大可铸造 = 2000 * 100 / 150 = $1333.33
//
// 3. 使用流程:
//    存入抵押品:
//    1. 调用 depositCollateral()，发送 ETH
//    
//    铸造稳定币:
//    1. 调用 mintStablecoin(amount)
//    2. 确保不超过最大可铸造金额
//    
//    偿还债务:
//    1. 调用 burnStablecoin(amount) 销毁稳定币
//    
//    提取抵押品:
//    1. 调用 withdrawCollateral(amount)
//    2. 确保提取后抵押率仍 >= 150%
//
// 4. 清算机制:
//    - 当健康因子 < 150% 时，头寸可被清算
//    - 清算人支付债务（销毁稳定币）
//    - 清算人获得抵押品 + 5% 奖励
//    - 这激励人们维护系统健康
//
// 5. 与 DAI 的区别:
//    - 本合约是简化版，DAI 有更复杂的风险参数
//    - DAI 使用多抵押品（不仅是 ETH）
//    - DAI 有稳定费率（利息），本合约没有
//    - DAI 有去中心化治理（MKR 代币持有者）
//
// 6. 风险场景:
//    - ETH 价格暴跌: 可能导致大量清算
//    - 预言机故障: 价格数据错误
//    - 挤兑: 大量用户同时提取抵押品
//
// 7. 关键知识点:
//    - 超额抵押稳定币机制
//    - 价格预言机（Chainlink）
//    - 清算激励设计
//    - 健康因子计算
//    - 小数位数转换（8位 -> 18位）
//
