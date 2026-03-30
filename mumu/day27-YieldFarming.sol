
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol"; // 如果需要使用 SafeCast

// 用于获取 ERC-20 元数据(小数位数)的接口
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

/// @title 收益耕作平台
///     质押代币以随时间赚取奖励,可选紧急提取和管理员补充
contract YieldFarming is ReentrancyGuard {
    using SafeCast for uint256;  // what‘s this？

    // staking：下注 
    // 质押token
    IERC20 public stakingToken;
    // 奖励token
    IERC20 public rewardToken;

    uint256 public rewardRatePerSecond; // 每秒分配的奖励

    address public owner;

    uint8 public stakingTokenDecimals; // 存储质押代币的小数位数

    struct StakerInfo {
        uint256 stakedAmount;  // 质押数量
        uint256 rewardDebt;  // 奖励累积债务
        uint256 lastUpdate;  // 最后一次的更新时间
    }

    // map[useraddress] -> 质押信息
    mapping(address => StakerInfo) public stakers;

    // 质押
    event Staked(address indexed user, uint256 amount);
    // 取消质押
    event Unstaked(address indexed user, uint256 amount);
    // 获取奖励
    event RewardClaimed(address indexed user, uint256 amount);
    // 紧急提取
    event EmergencyWithdraw(address indexed user, uint256 amount);
    // 增加奖励
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

        // 尝试获取小数位数
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18; // 如果获取失败,默认为 18 位小数
        }
    }

    ///     质押代币以开始赚取奖励
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        updateRewards(msg.sender);

        // 收取质押token
        // 然后再更新存储，注意这个顺序
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount += amount;

        emit Staked(msg.sender, amount);
    }

    ///     取消质押代币并可选择领取奖励
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");

        updateRewards(msg.sender);

        // 先更新存储，再进行转账
        stakers[msg.sender].stakedAmount -= amount;
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    ///     领取累积的奖励
    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        stakers[msg.sender].rewardDebt = 0;
        rewardToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    ///     紧急取消质押而不领取奖励
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;

        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    ///     管理员可以补充奖励代币
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit RewardRefilled(msg.sender, amount);
    }

    ///     更新质押者的奖励
    function updateRewards(address user) internal {
        StakerInfo storage staker = stakers[user];

        if (staker.stakedAmount > 0) {
            uint256 timeDiff = block.timestamp - staker.lastUpdate;
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
            staker.rewardDebt += pendingReward; // 更新奖励债务
        }

        staker.lastUpdate = block.timestamp;
    }

    ///     查看待处理奖励而不领取
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

    ///     查看质押代币小数位数
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;
    }
}


/**

1. using SafeCast for uint256;


2. 取消质押和紧急提取有什么区别？
 */

/**
合约：YieldFarming- 收益农场
target: 实现流动性挖矿和质押奖励机制
key word：质押、奖励、流动性挖矿、时间加权

基本流程
1. 用户质押代币到合约
2. 合约记录质押数量和时间
3. 根据时间和数量计算奖励
4. 用户可随时领取奖励
5. 用户可取回质押的代币

奖励计算公式： 
    奖励 = 质押数量 * 将利率 * 时间

--》 这不就像我们的余额包？或者说是定期存款？

时间加权奖励系统
- 实时更新奖励，每次操作后触发更新
- 累积计算，奖励会不断的累积到rewardDebt
- 使用区块时间戳进行计算
- gas优化

需要考虑安全机制
- 放重入
- 奖池余额检查
- 紧急提取功能
- safemath防溢出


使用场景：
- 流动性池
- DAO 金库
- DeFi 激励措施
- GameFi 奖励系统
- 启动平台和代币分发
Uniswap 到 SushiSwap 再到 Curve 
 */

 /**
 其他：
 1. 其实觉得这跟day23的 simpleLending 借贷合约挺像的，只有存取，没有借
  */