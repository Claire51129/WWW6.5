//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Interface for fetching ERC20 token metadata (name, symbol, decimals)
interface IERC20Metadata is IERC20 {
  function decimals() external view returns (uint8);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
}

/// @title Yield Farming Platform
///    Stake tokens to earn rewards over time with optional emergency withdrawal and admin refills
contract YieldFarming is ReentrancyGuard {
  using SafeCast for uint256;

  IERC20 public stakingToken;
  IERC20 public rewardToken;

  uint256 public rewardRatePerSecond; // Rewards distributed per second
  address public owner;
  uint8 public stakingTokenDecimals; // Store the number of decimals for the reward token

  struct StakerInfo {
    uint256 stakedAmount;
    uint256 rewardDebt; // Used for calculating pending rewards
    uint256 lastUpdateTime; // Timestamp of the last update for this staker
  }

  mapping(address => StakerInfo) public stakers;

  event Staked(address indexed user, uint256 amount);
  event Unstaked(address indexed user, uint256 amount);
  event RewardsClaimed(address indexed user, uint256 amount);
  event EmergencyWithdrawn(address indexed user, uint256 amount);
  event RewardRateUpdated(uint256 newRewardRate);

  modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
  }

  constructor(
    address _stakingToken,
    address _rewardToken,
    uint256 _rewardRatePerSecond
  ) {
    owner = msg.sender;
    stakingToken = IERC20(_stakingToken);
    rewardToken = IERC20(_rewardToken);
    rewardRatePerSecond = _rewardRatePerSecond;

    // Fetch and store the decimals of the reward token
    try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
      stakingTokenDecimals = decimals;
    } catch (bytes memory) {
      stakingTokenDecimals = 18; // Default to 18 if not available
    }
  }

  ///stake tokens to earn rewards
  function stake(uint256 amount) external nonReentrant {
    require(amount > 0, "Cannot stake 0");

    updateRewards(msg.sender);

    stakingToken.transferFrom(msg.sender, address(this), amount);
    stakers[msg.sender].stakedAmount += amount;

    emit Staked(msg.sender, amount);
  }

  ///unstake tokens
  function unstake(uint256 amount) external nonReentrant {
    require(amount > 0, "Cannot unstake 0");
    require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

    updateRewards(msg.sender);

    stakers[msg.sender].stakedAmount -= amount;
    stakingToken.transfer(msg.sender, amount);

    emit Unstaked(msg.sender, amount);
  }

  ///claim accumulated rewards
  function claimRewards() external nonReentrant {
    updateRewards(msg.sender);

    uint256 reward = stakers[msg.sender].rewardDebt;
    require(reward > 0, "No rewards to claim");
    require(rewardToken.balanceOf(address(this)) >= reward, "Not enough rewards in contract");

    stakers[msg.sender].rewardDebt = 0;
    rewardToken.transfer(msg.sender, reward);
    emit RewardsClaimed(msg.sender, reward);
  }

  ///emergency unstake without claiming rewards
  function emergencyWithdraw() external nonReentrant {
    uint256 amount = stakers[msg.sender].stakedAmount;
    require(amount > 0, "No staked tokens to withdraw");

    stakers[msg.sender].stakedAmount = 0;
    stakers[msg.sender].rewardDebt = 0;
    stakers[msg.sender].lastUpdateTime = block.timestamp;

    require(stakingToken.transfer(msg.sender, amount), "Transfer failed");

    emit EmergencyWithdrawn(msg.sender, amount);
  }

  function refillRewards(uint256 amount) external onlyOwner {
    rewardToken.transferFrom(msg.sender, address(this), amount);

    emit RewardRateUpdated(rewardRatePerSecond);
  }

  ///Update rewards for a staker
  function updateRewards(address staker) internal {
    StakerInfo storage stakerData = stakers[staker];  //use storage to update the staker info
    if (stakerData.stakedAmount > 0) {
      uint256 timeElapsed = block.timestamp - stakerData.lastUpdateTime;
      uint256 rewardMultiplier = 10 ** uint256(stakingTokenDecimals); // Adjust for reward token decimals
      uint256 pendingReward = (timeElapsed * rewardRatePerSecond * stakerData.stakedAmount) / rewardMultiplier;
      stakerData.rewardDebt += pendingReward;
    }
    stakerData.lastUpdateTime = block.timestamp;
  }

  ///View pending rewards without claiming
  function pendingRewards(address user) external view returns (uint256) {
    StakerInfo memory staker = stakers[user];
    uint256 pendingReward = staker.rewardDebt;

    if(staker.stakedAmount > 0) {
      uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
      uint256 rewardMultiplier = 10 ** stakingTokenDecimals; // Adjust for reward token decimals
      pendingReward += (timeElapsed * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
    }

    return pendingReward;
  }

  ///View staking token decimals
  function getStakingTokenDecimals() external view returns (uint8) {
    return stakingTokenDecimals;
  }
}