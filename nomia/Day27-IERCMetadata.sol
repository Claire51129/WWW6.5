// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20 标准接口：用于和质押代币、奖励代币交互
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// 防重入攻击保护
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 安全类型转换库
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/// @notice 用于读取 ERC20 的元数据（比如 decimals）
/// @dev 有些 ERC20 合约支持这些函数，有些不一定支持
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

/// @title 收益耕作平台
/// @notice 用户质押 stakingToken，按时间获得 rewardToken
contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;

    // 用户拿来质押的代币
    IERC20 public stakingToken;

    // 发给用户的奖励代币
    IERC20 public rewardToken;

    // 每秒的奖励速率
    // 奖励公式里会乘上“质押数量”和“时间”
    uint256 public rewardRatePerSecond;

    // 合约管理员
    address public owner;

    // 记录质押代币的小数位数，方便奖励计算时做精度处理
    uint8 public stakingTokenDecimals;

    /// @notice 每个质押用户的状态
    struct StakerInfo {
        uint256 stakedAmount; // 当前质押数量
        uint256 rewardDebt;   // 已累计但还没领取的奖励
        uint256 lastUpdate;   // 上次奖励结算时间
    }

    // 每个地址对应一份质押信息
    mapping(address => StakerInfo) public stakers;

    // ===== 事件 =====
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(address indexed owner, uint256 amount);

    /// @notice 限制只有 owner 可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @param _stakingToken 质押代币地址
    /// @param _rewardToken 奖励代币地址
    /// @param _rewardRatePerSecond 每秒奖励速率
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        // 尝试读取 stakingToken 的 decimals
        // 如果目标代币没实现 decimals()，就默认按 18 位处理
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18;
        }
    }

    /// @notice 质押代币，开始赚奖励
    /// @dev 调用前用户需要先 approve 给本合约
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        // 先把用户在“这次操作前”的奖励结算出来
        // 否则旧奖励会丢
        updateRewards(msg.sender);

        // 把质押代币从用户转进合约
        stakingToken.transferFrom(msg.sender, address(this), amount);

        // 更新用户质押数量
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    /// @notice 解除质押，取回本金
    /// @dev 不会自动把奖励一起发出，奖励要单独 claim
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        // 先结算到当前时刻的奖励
        updateRewards(msg.sender);

        // 扣掉用户质押数量
        stakers[msg.sender].stakedAmount -= amount;

        // 把本金转回用户
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    /// @notice 领取当前累计的奖励
    function claimRewards() external nonReentrant {
        // 先更新最新奖励
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;

        require(reward > 0, "No rewards to claim");

        // 合约里必须有足够的奖励代币，否则无法发放
        require(
            rewardToken.balanceOf(address(this)) >= reward,
            "Insufficient reward token balance"
        );

        // 先清零，再转账，符合更安全的状态更新顺序
        stakers[msg.sender].rewardDebt = 0;

        rewardToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    /// @notice 紧急提取：直接拿回本金，放弃所有未领取奖励
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        // 清空用户状态
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        // 只退本金，不发奖励
        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    /// @notice 管理员补充奖励池
    /// @dev owner 也需要先 approve 奖励代币给本合约
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit RewardRefilled(msg.sender, amount);
    }

    /// @notice 内部函数：更新某个用户的累计奖励
    /// @dev 核心逻辑：
    ///      新奖励 = 经过时间 × 每秒奖励速率 × 质押数量 / 精度因子
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        // 只有真的有质押，才会继续产生奖励
        if (staker.stakedAmount > 0) {
            // 距离上次结算过去了多久
            uint256 timeDiff = block.timestamp - staker.lastUpdate;

            // 例如 stakingToken 是 18 位小数，这里就是 1e18
            // 用来把 stakedAmount 从最小单位缩回正常比例
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;

            // 核心奖励公式
            uint256 pendingReward =
                (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;

            // 加到用户未领取奖励里
            staker.rewardDebt += pendingReward;
        }

        // 无论有没有质押，都把更新时间刷新到当前
        staker.lastUpdate = block.timestamp;
    }

    /// @notice 查看某个用户此刻可领取的奖励
    /// @dev 这是 view，只是模拟计算，不会真的修改链上状态
    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];

        // 先取已经累计进 rewardDebt 的部分
        uint256 pendingReward = staker.rewardDebt;

        // 再把“从上次更新到现在”的新奖励模拟算出来
        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;

            pendingReward +=
                (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }

        return pendingReward;
    }

    /// @notice 查看质押代币的小数位数
    /// @dev 其实 stakingTokenDecimals 是 public，这个函数有点重复
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}