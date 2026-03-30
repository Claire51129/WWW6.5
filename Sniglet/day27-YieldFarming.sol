// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// ✅ 这里改了路径！
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
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
        uint256 lastUpdate;
    }

    mapping(address => StakerInfo) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(address indexed owner, uint256 amount);

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

        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch {
            stakingTokenDecimals = 18;
        }
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        updateRewards(msg.sender);

        bool success = stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        
        stakers[msg.sender].stakedAmount += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        updateRewards(msg.sender);

        stakers[msg.sender].stakedAmount -= amount;
        bool success = stakingToken.transfer(msg.sender, amount);
        require(success, "Transfer failed");
        
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external nonReentrant {
        uint256 reward = pendingRewards(msg.sender);
        require(reward > 0, "No rewards to claim");

        updateRewards(msg.sender);
        stakers[msg.sender].rewardDebt = 0;

        bool success = rewardToken.transfer(msg.sender, reward);
        require(success, "Reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    function refillRewards(uint256 amount) external onlyOwner {
        bool success = rewardToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Refill failed");
        emit RewardRefilled(msg.sender, amount);
    }

    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount == 0) {
            staker.lastUpdate = block.timestamp;
            return;
        }
        
        if (staker.lastUpdate == 0) {
            staker.lastUpdate = block.timestamp;
            return;
        }

        uint256 timeDiff = block.timestamp - staker.lastUpdate;
        uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
        uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;

        staker.rewardDebt += pendingReward;
        staker.lastUpdate = block.timestamp;
    }

    function pendingRewards(address user) public view returns (uint256) {
        StakerInfo memory staker = stakers[user];
        uint256 pending = staker.rewardDebt;

        if (staker.stakedAmount > 0 && staker.lastUpdate > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            pending += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }

        return pending;
    }

    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}