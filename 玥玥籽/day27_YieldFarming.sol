// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract YieldFarming is ReentrancyGuard {

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRatePerSecond;
    address public owner;

    uint256[4] public lockPeriods = [0, 30 days, 90 days, 180 days];
    uint256[4] public rewardMultipliers = [100, 125, 150, 200];

    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdate;
        uint256 lockUntil;
        uint256 rewardMultiplier;
    }

    mapping(address => StakerInfo) public stakers;

    event Staked(address indexed user, uint256 amount, uint256 lockPeriod, uint256 multiplier);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(address indexed owner, uint256 amount);

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
    }

    function stake(uint256 amount, uint256 lockTierIndex) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        require(lockTierIndex < 4, "Invalid lock tier");

        _updateRewards(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        uint256 newLockUntil = block.timestamp + lockPeriods[lockTierIndex];
        if (newLockUntil > stakers[msg.sender].lockUntil) {
            stakers[msg.sender].lockUntil = newLockUntil;
            stakers[msg.sender].rewardMultiplier = rewardMultipliers[lockTierIndex];
        }

        emit Staked(msg.sender, amount, lockPeriods[lockTierIndex], stakers[msg.sender].rewardMultiplier);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Insufficient staked amount");
        require(block.timestamp >= stakers[msg.sender].lockUntil, "Still in lock period");

        _updateRewards(msg.sender);
        stakers[msg.sender].stakedAmount -= amount;

        if (stakers[msg.sender].stakedAmount == 0) {
            stakers[msg.sender].rewardMultiplier = 100;
            stakers[msg.sender].lockUntil = 0;
        }

        stakingToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external nonReentrant {
        _updateRewards(msg.sender);
        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward balance");

        stakers[msg.sender].rewardDebt = 0;
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;
        stakers[msg.sender].lockUntil = 0;
        stakers[msg.sender].rewardMultiplier = 100;

        stakingToken.transfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardRefilled(msg.sender, amount);
    }

    function _updateRewards(address user) internal {
        StakerInfo storage s = stakers[user];
        if (s.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - s.lastUpdate;
            uint256 multiplier = s.rewardMultiplier > 0 ? s.rewardMultiplier : 100;
            uint256 pending = (timeDiff * rewardRatePerSecond * s.stakedAmount * multiplier) / (1e18 * 100);
            s.rewardDebt += pending;
        }
        s.lastUpdate = block.timestamp;
    }

    function pendingRewards(address user) external view returns (uint256) {
        StakerInfo memory s = stakers[user];
        uint256 pending = s.rewardDebt;
        if (s.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - s.lastUpdate;
            uint256 multiplier = s.rewardMultiplier > 0 ? s.rewardMultiplier : 100;
            pending += (timeDiff * rewardRatePerSecond * s.stakedAmount * multiplier) / (1e18 * 100);
        }
        return pending;
    }

    function getLockTimeLeft(address user) external view returns (uint256) {
        if (block.timestamp >= stakers[user].lockUntil) return 0;
        return stakers[user].lockUntil - block.timestamp;
    }
}
