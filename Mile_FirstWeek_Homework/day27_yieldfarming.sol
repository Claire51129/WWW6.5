// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title YieldFarming
 * @dev 实现流动性挖矿和质押奖励机制
 * 文件名: day27_yield_farming.sol
 */
contract day27_yield_farming is ReentrancyGuard, Ownable {
    IERC20 public immutable stakingToken; // 用户质押的代币
    IERC20 public immutable rewardToken;  // 发放的奖励代币

    uint256 public rewardRate; // 每秒每单位质押代币获得的奖励 (以 1e18 为基数进行计算以防止精度丢失)

    struct Staker {
        uint256 amount;             // 质押总额
        uint256 rewardDebt;         // 已结算但未领取的奖励
        uint256 lastUpdateTime;     // 上次更新奖励的时间戳
    }

    mapping(address => Staker) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    /**
     * @param _stakingToken 质押代币地址
     * @param _rewardToken 奖励代币地址
     * @param _rewardRate 每秒奖励率
     */
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    // --- 核心逻辑 ---

    /**
     * @dev 更新并结算用户的奖励
     */
    function _updateReward(address _account) internal {
        Staker storage staker = stakers[_account];
        if (staker.amount > 0) {
            uint256 pending = _calculatePendingReward(_account);
            staker.rewardDebt += pending;
        }
        staker.lastUpdateTime = block.timestamp;
    }

    /**
     * @dev 计算待领取的奖励
     * 公式：质押数量 * 奖励率 * 时间差
     */
    function _calculatePendingReward(address _account) internal view returns (uint256) {
        Staker storage staker = stakers[_account];
        if (staker.amount == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
        return (staker.amount * rewardRate * timeElapsed) / 1e18;
    }

    /**
     * @dev 质押代币
     */
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0");
        
        _updateReward(msg.sender);
        
        stakers[msg.sender].amount += _amount;
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Stake transfer failed");
        
        emit Staked(msg.sender, _amount);
    }

    /**
     * @dev 提取质押代币
     */
    function unstake(uint256 _amount) external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.amount >= _amount, "Insufficient stake balance");
        
        _updateReward(msg.sender);
        
        staker.amount -= _amount;
        require(stakingToken.transfer(msg.sender, _amount), "Unstake transfer failed");
        
        emit Unstaked(msg.sender, _amount);
    }

    /**
     * @dev 领取奖励
     */
    function claimRewards() external nonReentrant {
        _updateReward(msg.sender);
        
        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        
        stakers[msg.sender].rewardDebt = 0;
        require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
        
        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev 紧急提取本金（放弃所有未结算奖励，用于应对合约极端情况）
     */
    function emergencyWithdraw() external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        uint256 amount = staker.amount;
        require(amount > 0, "Nothing to withdraw");

        staker.amount = 0;
        staker.rewardDebt = 0;
        staker.lastUpdateTime = block.timestamp;

        require(stakingToken.transfer(msg.sender, amount), "Emergency transfer failed");
        emit EmergencyWithdraw(msg.sender, amount);
    }

    // --- 管理员函数 ---

    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }

    /**
     * @dev 查看当前可领取的奖励（用于前端显示）
     */
    function pendingRewards(address _account) external view returns (uint256) {
        return stakers[_account].rewardDebt + _calculatePendingReward(_account);
    }
}