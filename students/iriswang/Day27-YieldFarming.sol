// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IERC20
 * @dev 手动定义 ERC20 接口（只需本合约用到的函数）
 */
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title IERC20Metadata
 * @dev 为了获取代币的小数位数
 */
interface IERC20Metadata {
    function decimals() external view returns (uint8);
}

/**
 * @title ReentrancyGuard
 * @dev 手动实现简单的重入锁（OpenZeppelin 的简化版）
 */
abstract contract ReentrancyGuard {
    uint256 private _status;

    constructor() {
        _status = 1;
    }

    modifier nonReentrant() {
        require(_status != 2, "Reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

/**
 * @title YieldFarming
 * @notice 一个简单的收益农场（流动性挖矿）合约
 * @dev 用户质押一种代币（stakingToken），按时间线性获得另一种代币（rewardToken）作为奖励
 */
contract YieldFarming is ReentrancyGuard {
    // ========== 状态变量 ==========
    IERC20 public stakingToken;          // 用户质押的代币（例如 LP Token）
    IERC20 public rewardToken;           // 奖励代币（例如 FARM）
    uint256 public rewardRatePerSecond;   // 每秒每个「基础单位」质押代币产生的奖励数量
    address public owner;                // 合约所有者（管理员）

    uint8 public stakingTokenDecimals;   // 质押代币的小数位数（如 18）

    struct StakerInfo {
        uint256 stakedAmount;            // 当前质押数量
        uint256 rewardDebt;              // 已累计但未领取的奖励
        uint256 lastUpdateTime;          // 上次更新用户奖励的时间戳
    }

    mapping(address => StakerInfo) public stakers;

    // 事件
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardRefilled(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // ========== 构造函数 ==========
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

    // ========== 用户操作 ==========
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

    // ========== 管理员操作 ==========
    function refillRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot refill 0");
        rewardToken.transferFrom(msg.sender, address(this), amount);
        emit RewardRefilled(amount);
    }

    // ========== 内部函数 ==========
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];
        if (staker.stakedAmount > 0) {
            uint256 pending = pendingRewards(user);
            staker.rewardDebt += pending;
        }
        staker.lastUpdateTime = block.timestamp;
    }

    // ========== 查询函数 ==========
    function pendingRewards(address user) public view returns (uint256) {
        StakerInfo memory staker = stakers[user];
        if (staker.stakedAmount == 0) return 0;
        uint256 timeElapsed = block.timestamp - staker.lastUpdateTime;
        if (timeElapsed == 0) return 0;
        return (staker.stakedAmount * rewardRatePerSecond * timeElapsed) / (10 ** stakingTokenDecimals);
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
