// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// ERC-20 元数据接口 - 在标准 IERC20 基础上增加了 decimals、name、symbol 查询
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);     // 小数位数
    function name() external view returns (string memory); // 代币名称
    function symbol() external view returns (string memory); // 代币符号
}

// 收益农场合约
// 核心逻辑：用户质押代币 → 按时间累积奖励 → 随时领取奖励或取回本金
contract YieldFarming is ReentrancyGuard {

    using SafeCast for uint256;  // 安全类型转换库，防止数值溢出

    IERC20 public stakingToken;   // 质押代币（用户存入的代币，比如 UNI）
    IERC20 public rewardToken;    // 奖励代币（平台发给用户的奖励，比如 CAKE）
    // 两种代币可以是同一种，也可以不同
    // 例如：质押 ETH 挖 SUSHI，或者质押 CAKE 挖更多 CAKE

    uint256 public rewardRatePerSecond;  // 每秒每单位质押量的奖励数量
    address public owner;                 // 管理员
    uint8 public stakingTokenDecimals;    // 质押代币的小数位数（用于精度计算）

    // 质押者信息结构体
    struct StakerInfo {
        uint256 stakedAmount;   // 质押了多少代币
        uint256 rewardDebt;     // 已累积但未领取的奖励
        uint256 lastUpdate;     // 上次更新奖励的时间戳
    }

    // 用户地址 => 质押信息
    mapping(address => StakerInfo) public stakers;

    // 事件
    event Staked(address indexed user, uint256 amount);            // 质押
    event Unstaked(address indexed user, uint256 amount);           // 取消质押
    event RewardClaimed(address indexed user, uint256 amount);      // 领取奖励
    event EmergencyWithdraw(address indexed user, uint256 amount);  // 紧急提取
    event RewardRefilled(address indexed owner, uint256 amount);    // 管理员补充奖励

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 构造函数 - 设置质押代币、奖励代币和每秒奖励率
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
        // try-catch：如果代币合约实现了 decimals() 就用它的值
        // 如果没实现（有些老代币没有这个函数），就默认 18 位
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18;
        }
    }

    // 质押 - 用户存入代币开始赚取奖励
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        // 先把之前累积的奖励算清楚，再增加新的质押量
        // 否则新存入的部分会被错误地计算从上次更新到现在的奖励
        updateRewards(msg.sender);

        // 从用户钱包转入质押代币（用户需要先 approve）
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    // 取消质押 - 取回部分或全部质押的代币
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        // 先结算奖励，再减少质押量
        updateRewards(msg.sender);

        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount);  // 把代币还给用户

        emit Unstaked(msg.sender, amount);
    }

    // 领取奖励 - 只取走累积的奖励，本金不动
    function claimRewards() external nonReentrant {
        // 先结算最新的奖励
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        // 检查合约里奖励代币够不够发
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        stakers[msg.sender].rewardDebt = 0;  // 清零已领取的奖励
        rewardToken.transfer(msg.sender, reward);  // 发送奖励代币给用户

        emit RewardClaimed(msg.sender, reward);
    }

    // 紧急提取 - 放弃所有未领取的奖励，只取回本金
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        // 清零所有数据（不结算奖励）
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);  // 只返还本金

        emit EmergencyWithdraw(msg.sender, amount);
    }

    // 补充奖励 - 管理员往合约里充值奖励代币
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardRefilled(msg.sender, amount);
    }

    // 更新奖励 - 内部函数，计算用户从上次更新到现在累积了多少奖励
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount > 0) {
            // 距离上次更新过了多少秒
            uint256 timeDiff = block.timestamp - staker.lastUpdate;

            // 精度乘数，和代币小数位数对齐
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;

            // 奖励计算公式：经过的秒数 × 每秒奖励率 × 质押数量 / 精度乘数
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;

            // 累加到待领取奖励中
            staker.rewardDebt += pendingReward;
        }

        // 更新时间戳为当前，下次计算从这里开始
        staker.lastUpdate = block.timestamp;
    }

    // 查看待领取奖励 - 只查不改，不消耗 gas
    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];

        // 从已记录的奖励开始
        uint256 pendingReward = staker.rewardDebt;

        // 加上从上次更新到现在新产生的奖励
        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }

        return pendingReward;
    }

    // 查看质押代币的小数位数
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}