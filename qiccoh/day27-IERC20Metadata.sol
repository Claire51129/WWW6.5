
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//难不太懂...
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
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
    using SafeCast for uint256;

    IERC20 public stakingToken;
    // 用户将质押(锁定)到合约中的代币
    IERC20 public rewardToken;
    // 这是用户存入农场的资产

    uint256 public rewardRatePerSecond; // 每秒分配的奖励

    address public owner;//存储管理员的钱包地址 

    uint8 public stakingTokenDecimals; // 存储质押代币的小数位数

 
    mapping(address => StakerInfo) public stakers;
/**- 他们质押了多少
- 他们积累了多少奖励
- 他们的奖励上次更新是什么时候**/
   struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdate;
    }


// 用户质押代币到农场时触发
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);//用户取消质押
    event RewardClaimed(address indexed user, uint256 amount);//用户领取他们的待处理奖励而不取消质押时触发
    event EmergencyWithdraw(address indexed user, uint256 amount);//谁进行了紧急退出以及他们提取了多少。
    event RewardRefilled(address indexed owner, uint256 amount);//当管理员用新的奖励代币补充合约时触发

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
/**- 用户将质押什么代币?
- 他们将作为奖励赚取什么代币?
- 奖励应该多快分配?**/
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRatePerSecond
    ) {

        // 设置质押代币
        stakingToken = IERC20(_stakingToken);
        // 设置奖励代币
        rewardToken = IERC20(_rewardToken);
        //  设置奖励率
        rewardRatePerSecond = _rewardRatePerSecond;
        // 设置所有者
        owner = msg.sender;

        // 尝试获取小数位数
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;
        } catch (bytes memory) {
            stakingTokenDecimals = 18; // 如果获取失败,默认为 18 位小数
        }
    }

    ///     质押代币以开始赚取奖励
    /**
> 用户将一些代币发送到合约 →
> 我们存储他们的存款 →
> 他们立即开始**按秒**赚取奖励。
>**/
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");

        updateRewards(msg.sender);
// 拉入质押的代币
        stakingToken.transferFrom(msg.sender, address(this), amount);
        // 更新质押者的金额
        stakers[msg.sender].stakedAmount += amount;
// 发出质押事件
        emit Staked(msg.sender, amount);
    }

    ///     取消质押代币并可选择领取奖励
    // 锁定函数防止重入
    /**- `external`:任何人都可以调用它 — 只为他们自己。
- `nonReentrant`:我们锁定它以**防止重入攻击**，因为正在转移代币。**/
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot unstake 0");
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");
// 取消质押前更新奖励
        updateRewards(msg.sender);
// 减少质押金额
        stakers[msg.sender].stakedAmount -= amount;
        //  将代币转回用户
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    ///     领取累积的奖励

    // 收获你赚取的代币
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
    /**- 也许前端坏了。
- 也许用户只是急需他们的代币回来。
- 也许有突然的安全恐慌。

无论什么原因 —

用户应该有一种方式**立即退出**而不用担心待处理的奖励。**/
    function emergencyWithdraw() external nonReentrant {
        uint256 amount = stakers[msg.sender].stakedAmount;
        require(amount > 0, "Nothing staked");

        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdate = block.timestamp;
/**- **清零**用户的质押和奖励债务。
- **更新**他们的 `lastUpdate` 到当前时间(即使他们正在退出)。
- 这确保如果他们再次返回并质押，他们从新开始。**/
        stakingToken.transfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    ///     管理员可以补充奖励代币
    /**> 这就像给杂货店补货。 
> 新奖励进来 → 耕作继续而没有任何中断
**/
    function refillRewards(uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit RewardRefilled(msg.sender, amount);
    }

    ///     更新质押者的奖励
    /**每次用户**质押**、**取消质押**或**领取奖励**时，
我们需要**重新计算**他们基于以下因素赚了多少:
- **多长时间**他们一直在质押
- **多少**他们质押了
- **多快**奖励正在分配
这就是内部 `updateRewar`**/
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

