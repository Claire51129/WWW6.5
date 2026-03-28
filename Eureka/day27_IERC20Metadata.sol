// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";//重入保护
import "@openzeppelin/contracts/utils/math/SafeCast.sol"; //转换数字类型时保证安全

//创建标准 IERC20 接口的小扩展
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);//小数位数
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public rewardRatePerSecond; // 每秒分配的奖励，奖励生成的速度

    address public owner;

    uint8 public stakingTokenDecimals; // 存储质押代币的小数位数

    struct StakerInfo {
        uint256 stakedAmount;//质押代币数量
        uint256 rewardDebt;//跟踪用户已经赚取但尚未领取的奖励数量
        uint256 lastUpdate;//记录我们上次更新用户奖励的时间
    }

    mapping(address => StakerInfo) public stakers;//在农场内部单独跟踪每个人的位置 

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(address indexed owner, uint256 amount);//管理员补充奖励池代币

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        // 尝试获取小数位数
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18; // 如果获取失败,默认为 18 位小数
        }
    }

    //质押代币以开始赚取奖励
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        updateRewards(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    //取消质押代币并可选择领取奖励
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        updateRewards(msg.sender);//取消质押前更新奖励

        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    //领取累积的奖励
    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        stakers[msg.sender].rewardDebt = 0;
        rewardToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    // 紧急取消质押而不领取奖励
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    //管理员可以补充奖励代币
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit RewardRefilled(msg.sender, amount);
    }

    //更新质押者的奖励
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
            staker.rewardDebt += pendingReward;
        }

        staker.lastUpdate = block.timestamp;
    }

    //查看待处理奖励而不领取
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

    //查看质押代币小数位数，帮助前端处理数学
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}
