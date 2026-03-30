// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
}

contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

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

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
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

        try IERC20Metadata(_stakingToken).decimals() returns (uint8 d) {
            stakingTokenDecimals = d;
        } catch {
            stakingTokenDecimals = 18;
        }
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero amount");
        
        StakerInfo storage staker = stakers[msg.sender];
        
        // Fix: If first time staking, set lastUpdate to now to prevent 1970-yield exploit
        if (staker.lastUpdate == 0) {
            staker.lastUpdate = block.timestamp;
        } else {
            updateRewards(msg.sender);
        }

        stakingToken.transferFrom(msg.sender, address(this), amount);
        staker.stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        StakerInfo storage staker = stakers[msg.sender];
        require(staker.stakedAmount >= amount, "Exceeds stake");

        updateRewards(msg.sender);

        staker.stakedAmount -= amount;
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
        StakerInfo storage staker = stakers[msg.sender];
        uint256 amount = staker.stakedAmount;
        require(amount > 0, "Nothing staked");

        staker.stakedAmount = 0;
        staker.rewardDebt = 0;
        staker.lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

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

    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory staker = stakers[user];
        uint256 totalReward = staker.rewardDebt;

        if (staker.stakedAmount > 0 && staker.lastUpdate > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            totalReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        }
        return totalReward;
    }
}
