// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20 接口，用于质押和奖励代币
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// 防重入攻击保护
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 安全类型转换（可选使用）
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// ERC20 元数据接口（获取代币小数位、名字、符号）
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

/// @title 收益耕作平台（Yield Farming）
/// @notice 用户可以质押代币赚取奖励，支持紧急提取和管理员补充奖励
contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;

    // ===== 基本信息 =====
    IERC20 public stakingToken;       // 用户质押的代币
    IERC20 public rewardToken;        // 奖励代币
    uint256 public rewardRatePerSecond; // 每秒发放的奖励数量
    address public owner;             // 合约拥有者
    uint8 public stakingTokenDecimals; // 质押代币的小数位数

    // ===== 每个用户的质押信息 =====
    struct StakerInfo {
        uint256 stakedAmount; // 当前质押数量
        uint256 rewardDebt;   // 已累积未领取奖励
        uint256 lastUpdate;   // 上次更新时间
    }

    // 用户地址 → 质押信息
    mapping(address => StakerInfo) public stakers;

    // ===== 事件 =====
    event Staked(address indexed user, uint256 amount);          // 质押事件
    event Unstaked(address indexed user, uint256 amount);        // 取消质押事件
    event RewardClaimed(address indexed user, uint256 amount);  // 奖励领取事件
    event EmergencyWithdraw(address indexed user, uint256 amount); // 紧急提取事件
    event RewardRefilled(address indexed owner, uint256 amount);   // 管理员补充奖励事件

    // ===== 权限修饰器 =====
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // ===== 构造函数 =====
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        // 尝试获取代币小数位，如果失败默认 18
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18;
        }
    }

    // ===== 用户质押代币 =====
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        updateRewards(msg.sender); // 更新奖励
        stakingToken.transferFrom(msg.sender, address(this), amount); // 转入代币
        stakers[msg.sender].stakedAmount += amount;
        emit Staked(msg.sender, amount);
    }

    // ===== 用户取消质押 =====
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");
        updateRewards(msg.sender); // 更新奖励
        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount); // 返回质押代币
        emit Unstaked(msg.sender, amount);
    }

    // ===== 领取奖励 =====
    function claimRewards() external nonReentrant {
        updateRewards(msg.sender); // 更新奖励
        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        stakers[msg.sender].rewardDebt = 0; // 清零
        rewardToken.transfer(msg.sender, reward); // 发放奖励
        emit RewardClaimed(msg.sender, reward);
    }

    // ===== 紧急提取质押代币，不领取奖励 =====
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        // 清空用户质押和奖励记录
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount); // 发回质押代币
        emit EmergencyWithdraw(msg.sender, amount);
    }

    // ===== 管理员补充奖励代币 =====
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardRefilled(msg.sender, amount);
    }

    // ===== 更新用户奖励 =====
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];
        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate; // 时间差
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            // 计算待领取奖励
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
            staker.rewardDebt += pendingReward;
        }
        staker.lastUpdate = block.timestamp; // 更新时间
    }

    // ===== 查看待领取奖励 =====
    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];
        uint256 pendingReward = staker.rewardDebt;
        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }
        return pendingReward;
    }

    // ===== 查看质押代币小数位数 =====
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}