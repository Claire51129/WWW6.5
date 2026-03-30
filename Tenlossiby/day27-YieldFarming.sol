// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 合约
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// ==================== 自定义接口 ====================

/// @title ERC20 元数据接口
/// @dev 用于获取代币的小数位数、名称和符号
/// @dev 标准 IERC20 不包含这些信息，需要扩展接口
interface IERC20Metadata is IERC20 {
    /// @notice 获取代币小数位数
    /// @return 小数位数（通常为 18）
    function decimals() external view returns (uint8);
    
    /// @notice 获取代币名称
    /// @return 代币全称
    function name() external view returns (string memory);
    
    /// @notice 获取代币符号
    /// @return 代币简称（如 ETH、USDC）
    function symbol() external view returns (string memory);
}

/// @title 收益耕作合约
/// @title Yield Farming Platform
/// @dev 用户质押代币以随时间赚取奖励
/// @dev 支持紧急提取和管理员补充奖励
/// @dev 使用奖励债务（reward debt）模式计算收益
contract YieldFarming is ReentrancyGuard {
    
    // 使用 SafeCast 库进行安全的类型转换
    using SafeCast for uint256;

    // ==================== 状态变量 ====================
    
    /// @notice 质押代币合约接口
    /// @dev 用户质押的这种代币
    IERC20 public stakingToken;
    
    /// @notice 奖励代币合约接口
    /// @dev 用户获得的奖励是这种代币
    IERC20 public rewardToken;

    /// @notice 每秒分配的奖励数量
    /// @dev 这是全局奖励速率，不是每用户的
    /// @dev 实际奖励按质押比例分配
    uint256 public rewardRatePerSecond;

    /// @notice 合约所有者地址
    /// @dev 拥有管理权限，可以补充奖励
    address public owner;

    /// @notice 质押代币的小数位数
    /// @dev 用于计算奖励时的精度调整
    /// @dev 通常为 18，但某些代币可能不同（如 USDC 是 6）
    uint8 public stakingTokenDecimals;

    /// @notice 质押者信息结构体
    /// @dev 记录每个用户的质押状态和奖励信息
    struct StakerInfo {
        uint256 stakedAmount;    // 已质押的代币数量
        uint256 rewardDebt;      // 已累积但尚未领取的奖励
        uint256 lastUpdate;      // 上次更新奖励的时间戳
    }

    /// @notice 质押者信息映射
    /// @dev 用户地址 => 质押信息
    mapping(address => StakerInfo) public stakers;

    // ==================== 事件 ====================
    
    /// @notice 质押事件
    /// @param user 用户地址
    /// @param amount 质押数量
    event Staked(address indexed user, uint256 amount);
    
    /// @notice 取消质押事件
    /// @param user 用户地址
    /// @param amount 取消质押数量
    event Unstaked(address indexed user, uint256 amount);
    
    /// @notice 领取奖励事件
    /// @param user 用户地址
    /// @param amount 奖励数量
    event RewardClaimed(address indexed user, uint256 amount);
    
    /// @notice 紧急提取事件
    /// @param user 用户地址
    /// @param amount 提取数量
    event EmergencyWithdraw(address indexed user, uint256 amount);
    
    /// @notice 补充奖励事件
    /// @param owner 管理员地址
    /// @param amount 补充的奖励数量
    event RewardRefilled(address indexed owner, uint256 amount);

    // ==================== 修饰符 ====================
    
    /// @notice 仅所有者修饰符
    /// @dev 限制只有合约所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // ==================== 构造函数 ====================
    
    /// @notice 创建收益耕作合约
    /// @param _stakingToken 质押代币合约地址
    /// @param _rewardToken 奖励代币合约地址
    /// @param _rewardRatePerSecond 每秒奖励数量
    /// @dev 尝试获取质押代币的小数位数，失败则默认为 18
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        // 尝试获取质押代币的小数位数
        // 使用 try-catch 防止某些代币没有实现 decimals()
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            // 如果获取失败，默认为 18 位小数（标准 ERC20）
            stakingTokenDecimals = 18;
        }
    }

    // ==================== 核心功能 ====================
    
    /// @notice 质押代币
    /// @param amount 要质押的数量
    /// @dev 用户需要提前授权合约使用其代币
    /// @dev 质押后开始累积奖励
    function stake(uint256 amount) external nonReentrant {
        // 检查质押数量大于 0
        require(amount > 0, "Cannot stake 0");

        // 更新用户奖励（计算从上次更新到现在的奖励）
        updateRewards(msg.sender);

        // 从用户账户转移质押代币到合约
        stakingToken.transferFrom(msg.sender, address(this), amount);
        
        // 增加用户的质押数量
        stakers[msg.sender].stakedAmount += amount;

        // 触发质押事件
        emit Staked(msg.sender, amount);
    }

    /// @notice 取消质押代币
    /// @param amount 要取消质押的数量
    /// @dev 取消质押时会自动更新奖励
    function unstake(uint256 amount) external nonReentrant {
        // 检查取消质押数量大于 0
        require(amount > 0, "Cannot unstake 0");
        // 检查用户有足够的质押数量
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        // 更新用户奖励
        updateRewards(msg.sender);

        // 减少用户的质押数量
        stakers[msg.sender].stakedAmount -= amount;
        
        // 将质押代币返还给用户
        stakingToken.transfer(msg.sender, amount);

        // 触发取消质押事件
        emit Unstaked(msg.sender, amount);
    }

    /// @notice 领取累积的奖励
    /// @dev 将 rewardDebt 中累积的奖励转给用户
    function claimRewards() external nonReentrant {
        // 更新用户奖励（计算最新奖励）
        updateRewards(msg.sender);

        // 获取可领取的奖励数量
        uint256 reward = stakers[msg.sender].rewardDebt;
        
        // 检查有奖励可领取
        require(reward > 0, "No rewards to claim");
        // 检查合约有足够的奖励代币余额
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        // 清空用户的奖励债务
        stakers[msg.sender].rewardDebt = 0;
        
        // 将奖励代币转给用户
        rewardToken.transfer(msg.sender, reward);

        // 触发领取奖励事件
        emit RewardClaimed(msg.sender, reward);
    }

    /// @notice 紧急提取质押代币
    /// @dev 紧急情况下可以不领取奖励直接取回质押
    /// @dev 这会清空用户的所有奖励
    function emergencyWithdraw() external nonReentrant {
        // 获取用户的质押数量
        uint256 amount = stakers[msg.sender].stakedAmount;
        
        // 检查有质押可取
        require(amount > 0, "Nothing staked");

        // 清空用户的所有状态（放弃奖励）
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        // 将质押代币返还给用户
        stakingToken.transfer(msg.sender, amount);

        // 触发紧急提取事件
        emit EmergencyWithdraw(msg.sender, amount);
    }

    // ==================== 管理功能 ====================
    
    /// @notice 补充奖励代币
    /// @param amount 要补充的奖励数量
    /// @dev 只有合约所有者可以调用
    /// @dev 需要提前授权合约使用奖励代币
    function refillRewards(uint256 amount) external onlyOwner {
        // 从所有者账户转移奖励代币到合约
        rewardToken.transferFrom(msg.sender, address(this), amount);

        // 触发补充奖励事件
        emit RewardRefilled(msg.sender, amount);
    }

    // ==================== 内部函数 ====================
    
    /// @notice 更新用户的奖励
    /// @param user 用户地址
    /// @dev 内部函数，在质押、取消质押、领取奖励时调用
    /// @dev 计算从 lastUpdate 到现在应得的奖励
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        // 只有当用户有质押时才计算奖励
        if (staker.stakedAmount > 0) {
            // 计算时间差（秒）
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            
            // 计算奖励倍数（用于精度调整）
            // 10^decimals 用于将计算结果标准化
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            
            // 计算待领取的奖励
            // 公式：时间差 * 每秒奖励 * 质押数量 / 精度倍数
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
            
            // 累加到用户的奖励债务
            staker.rewardDebt += pendingReward;
        }

        // 更新上次计算时间
        staker.lastUpdate = block.timestamp;
    }

    // ==================== 查询函数 ====================
    
    /// @notice 查看用户的待领取奖励
    /// @param user 用户地址
    /// @return 待领取的奖励数量
    /// @dev view 函数，不消耗 gas
    /// @dev 包含已累积的 rewardDebt 和当前正在累积的奖励
    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];

        // 从 rewardDebt 开始
        uint256 pendingReward = staker.rewardDebt;

        // 如果用户有质押，计算从 lastUpdate 到现在的奖励
        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }

        return pendingReward;
    }

    /// @notice 查看质押代币的小数位数
    /// @return 小数位数
    /// @dev view 函数，不消耗 gas
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}

// ==================== 合约设计要点说明 ====================
//
// 1. 收益耕作（Yield Farming）核心概念:
//    - 质押（Stake）: 用户将代币锁定在合约中以获得奖励
//    - 奖励（Reward）: 按时间和质押比例分发的代币
//    - 奖励债务（Reward Debt）: 已累积但未领取的奖励
//    - 紧急提取: 在紧急情况下放弃奖励取回本金
//
// 2. 奖励计算公式:
//    用户每秒奖励 = (用户质押数量 / 总质押数量) * 每秒总奖励
//    
//    简化版（本合约使用）:
//    新奖励 = 时间差 * rewardRatePerSecond * 质押数量 / 10^decimals
//    
//    示例:
//    - rewardRatePerSecond = 1000 (每秒 1000 个奖励代币)
//    - 用户质押 1000 个代币（18 位小数）
//    - 过了 10 秒
//    - 新奖励 = 10 * 1000 * 1000e18 / 1e18 = 10,000 个奖励代币
//
// 3. 使用流程:
//    用户质押:
//    1. 授权合约使用质押代币: stakingToken.approve(farmAddress, amount)
//    2. 调用 stake(amount) 开始质押
//    3. 奖励开始自动累积
//    
//    领取奖励:
//    1. 调用 claimRewards() 领取累积的奖励
//    2. 奖励代币会转移到用户账户
//    
//    取消质押:
//    1. 调用 unstake(amount) 取回部分或全部质押
//    2. 质押代币会返还给用户
//    
//    紧急提取:
//    1. 调用 emergencyWithdraw() 立即取回所有质押
//    2. 注意：这会放弃所有未领取的奖励！
//
// 4. 管理员操作:
//    补充奖励:
//    1. 授权合约使用奖励代币: rewardToken.approve(farmAddress, amount)
//    2. 调用 refillRewards(amount) 补充奖励池
//
// 5. 安全机制:
//    - ReentrancyGuard: 防止重入攻击
//    - 先更新状态，再转账（Checks-Effects-Interactions）
//    - 紧急提取功能：在合约出现问题时可以取回本金
//
// 6. 与真实 DeFi 协议的区别:
//    - 本合约使用固定 rewardRatePerSecond
//    - 真实协议通常根据区块奖励动态调整
//    - 真实协议可能有更多复杂的奖励机制（如 boost、锁仓期等）
//    - 本合约没有考虑代币通胀和通缩
//
// 7. 潜在问题:
//    - 如果 rewardRatePerSecond 设置过高，奖励池可能很快耗尽
//    - 没有设置最低质押期限，用户可以随时进出
//    - 使用 transfer() 而不是 call{}()（虽然金额固定相对安全）
//    - 没有暂停功能
//
// 8. 关键知识点:
//    - 时间加权奖励计算
//    - 精度处理（decimals）
//    - 状态更新模式（先更新，后转账）
//    - try-catch 处理外部调用失败
