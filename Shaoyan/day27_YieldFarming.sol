// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 最小 ERC20 接口
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// 获取 decimals
interface IERC20Metadata {
    function decimals() external view returns (uint8);
}

// 简化版 ReentrancyGuard
contract ReentrancyGuard {
    uint256 private unlocked = 1;

    modifier nonReentrant() {
        require(unlocked == 1, "ReentrancyGuard");
        unlocked = 0;
        _;
        unlocked = 1;
    }
}

contract YieldFarming is ReentrancyGuard {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRatePerSecond;
    address public owner;

    uint8 public stakingTokenDecimals;

    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdateTime;
    }

    mapping(address => StakerInfo) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {
        require(_stakingToken != address(0), "Invalid staking token");
        require(_rewardToken != address(0), "Invalid reward token");
        require(_rewardRatePerSecond > 0, "Invalid reward rate");

        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRatePerSecond = _rewardRatePerSecond;
        owner = msg.sender;

        stakingTokenDecimals = IERC20Metadata(_stakingToken).decimals();
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        updateRewards(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Insufficient balance");

        updateRewards(msg.sender);

        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards");

        stakers[msg.sender].rewardDebt = 0;
        rewardToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "No stake");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdateTime = 0;

        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function refillRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot refill 0");

        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit RewardRefilled(amount);
    }

    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount > 0) {
            uint256 pending = pendingRewards(user);
            staker.rewardDebt += pending;
        }

        staker.lastUpdateTime = block.timestamp;
    }

    function pendingRewards(address user) public view returns (uint256) {
        StakerInfo memory staker = stakers[user];

        if (staker.stakedAmount == 0) return 0;

        uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
        if (timeElapsed == 0) return 0;

        uint256 reward =
            (staker.stakedAmount * rewardRatePerSecond * timeElapsed)
            / (10 ** stakingTokenDecimals);

        return reward;
    }

    function getTotalRewards(address user) external view returns (uint256) {
        return stakers[user].rewardDebt + pendingRewards(user);
    }

    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }

    function getRewardBalance() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }
}