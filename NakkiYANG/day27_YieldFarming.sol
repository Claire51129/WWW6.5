// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @dev 用于获取 ERC-20 元数据（如小数位数）的扩展接口
 */
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

/**
 * @title YieldFarming
 * @notice 质押代币赚取奖励的收益平台，支持奖励更新、紧急提取及管理员补充奖励。
 * @dev 采用简单的 linear reward 模型，根据质押时长和金额计算奖励。
 */
contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;

    IERC20 public stakingToken;      // 用户质押的代币地址
    IERC20 public rewardToken;       // 平台发放的奖励代币地址

    uint256 public rewardRatePerSecond; // 每单位质押代币每秒可获得的奖励量
    address public owner;               // 合约管理员

    uint8 public stakingTokenDecimals;  // 质押代币的小数位数，用于计算奖励时的精度对齐

    /**
     * @dev 质押者信息结构体
     * @param stakedAmount 用户当前质押的总额
     * @param rewardDebt 已累计但尚未领取的奖励金额
     * @param lastUpdate 上次更新奖励的时间戳
     */
    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdate;
    }

    // 用户地址 => 质押信息
    mapping(address => StakerInfo) public stakers;

    // 事件定义：便于前端监听交易状态
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(address indexed owner, uint256 amount);

    /**
     * @dev 权限控制：仅允许管理员操作
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @param _stakingToken 质押代币合约地址
     * @param _rewardToken 奖励代币合约地址
     * @param _rewardRatePerSecond 每秒奖励速率
     */
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        // 自动探测质押代币的小数位数，若该代币未实现 decimals() 则默认为 18
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch {
            stakingTokenDecimals = 18;
        }
    }

    /**
     * @notice 质押代币进入合约
     * @dev 质押前需先在代币合约中对本合约进行 approve 授权
     * @param amount 质押数量
     */
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        // 先结算之前的奖励，再增加新的质押额
        updateRewards(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice 赎回质押的代币
     * @dev 操作时会自动触发奖励结算并存入 rewardDebt
     * @param amount 赎回数量
     */
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        updateRewards(msg.sender);

        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @notice 提取所有已累计的奖励
     */
    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        // 状态清零并转账奖励代币
        stakers[msg.sender].rewardDebt = 0;
        rewardToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @notice 紧急提取：本金全额退回，放弃所有未领取的奖励
     * @dev 用于合约出现不可预知问题或奖励池枯竭时的极端情况
     */
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        // 重置用户所有状态，防止重入或数据残留
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    /**
     * @notice 管理员补充奖励代币池
     * @param amount 注入的奖励代币数量
     */
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardRefilled(msg.sender, amount);
    }

    /**
     * @dev 核心逻辑：计算并更新用户的奖励负债（rewardDebt）
     * @param user 需要更新奖励的用户地址
     */
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** uint256(stakingTokenDecimals);
            // 奖励公式：(时长 * 速率 * 质押量) / 精度对齐系数
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
            staker.rewardDebt += pendingReward;
        }

        // 记录本次更新时间
        staker.lastUpdate = block.timestamp;
    }

    /**
     * @notice 查看当前用户待领取的实时奖励总额（包含未结算部分）
     * @param user 用户地址
     * @return 返回实时奖励数量（以 rewardToken 的最小单位计）
     */
    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];
        uint256 pendingReward = staker.rewardDebt;

        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** uint256(stakingTokenDecimals);
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }

        return pendingReward;
    }

    /**
     * @notice 获取质押代币的小数位数
     */
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}