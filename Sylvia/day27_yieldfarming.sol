// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract YieldFarming is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    address public owner;

    uint256 public rewardPerSecond;
    uint256 public lastRewardTime;
    uint256 public accRewardPerShare; // 放大 1e12
    uint256 public totalStaked;

    struct UserInfo {
        uint256 amount;       // 用户质押数量
        uint256 rewardDebt;   // 用于计算 pending reward
    }

    mapping(address => UserInfo) public users;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardPerSecond
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardPerSecond = _rewardPerSecond;
        owner = msg.sender;
        lastRewardTime = block.timestamp;
    }

    // ================= 核心更新逻辑 =================

    function updatePool() public {
        if (block.timestamp <= lastRewardTime) return;

        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 reward = timeElapsed * rewardPerSecond;

        accRewardPerShare += (reward * 1e12) / totalStaked;

        lastRewardTime = block.timestamp;
    }

    // ================= 质押 =================

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");

        UserInfo storage user = users[msg.sender];

        updatePool();

        // 先发奖励
        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;
            if (pending > 0) {
                rewardToken.safeTransfer(msg.sender, pending);
                emit Claimed(msg.sender, pending);
            }
        }

        // 转入 staking token
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        user.amount += amount;
        totalStaked += amount;

        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;

        emit Staked(msg.sender, amount);
    }

    // ================= 取消质押 =================

    function unstake(uint256 amount) external nonReentrant {
        UserInfo storage user = users[msg.sender];
        require(user.amount >= amount, "Not enough");

        updatePool();

        uint256 pending = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;

        if (pending > 0) {
            rewardToken.safeTransfer(msg.sender, pending);
            emit Claimed(msg.sender, pending);
        }

        user.amount -= amount;
        totalStaked -= amount;

        stakingToken.safeTransfer(msg.sender, amount);

        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;

        emit Unstaked(msg.sender, amount);
    }

    // ================= 单独领取奖励 =================

    function claim() external nonReentrant {
        UserInfo storage user = users[msg.sender];

        updatePool();

        uint256 pending = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;
        require(pending > 0, "No reward");

        rewardToken.safeTransfer(msg.sender, pending);

        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;

        emit Claimed(msg.sender, pending);
    }

    // ================= 查看奖励 =================

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = users[_user];

        uint256 _accRewardPerShare = accRewardPerShare;

        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 timeElapsed = block.timestamp - lastRewardTime;
            uint256 reward = timeElapsed * rewardPerSecond;
            _accRewardPerShare += (reward * 1e12) / totalStaked;
        }

        return (user.amount * _accRewardPerShare) / 1e12 - user.rewardDebt;
    }

    // ================= 管理员 =================

    function setRewardPerSecond(uint256 _rate) external onlyOwner {
        updatePool();
        rewardPerSecond = _rate;
    }

    function depositRewards(uint256 amount) external onlyOwner {
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);
    }
}
