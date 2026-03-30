// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol"; // 如果需要使用 SafeCast
//当你在不同类型的数字之间移动时(如 uint256 → uint8)，如果你盲目地向下转换数字而不检查，你可能会溢出或截断值而没有意识到de漏洞
// 用于获取 ERC-20 元数据(小数位数)的接口
interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    //decimals()、name() 和 symbol() 在原始 ERC-20 标准中是可选的
    }
contract YieldFarming is ReentrancyGuard {

    using SafeCast for uint256; //用 SafeCast 库中的新安全函数扩展了原生 uint256 类型 允许我们直接在 uint256 数字上调用像 .toUint8()、.toUint128() 等方法
    IERC20 public stakingToken; //用户存入农场的资产
    IERC20 public rewardToken; //奖励赚取的代币
    uint256 public rewardRatePerSecond; // 每秒分配的奖励
    address public owner;
    uint8 public stakingTokenDecimals; //根据小数位数正确缩放,一些代币有 18 位小数(如 ETH),一些代币有 6 位小数(如 USDC)
    struct StakerInfo { 
    uint256 stakedAmount; //跟踪用户存入农场的质押代币数量
    uint256 rewardDebt; //用户已经赚取但尚未领取的奖励数量
    uint256 lastUpdate; //上次更新用户奖励的时间
    }
    mapping(address => StakerInfo) public stakers; //将每个用户的地址映射到他们的个人 StakerInfo 数据
    event Staked(address indexed user, uint256 amount); //用户质押代币到农场时触发
    event Unstaked(address indexed user, uint256 amount); //用户取消质押(提取)他们的代币时触发
    event RewardClaimed(address indexed user, uint256 amount);  //当用户领取他们的待处理奖励而不取消质押时触发
    event EmergencyWithdraw(address indexed user, uint256 amount); //用户立即取出他们的质押而不等待奖励时触发
    event RewardRefilled(address indexed owner, uint256 amount); //当管理员用新的奖励代币补充合约时触发
    modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
    }
    constructor(
    address _stakingToken,
    address _rewardToken,
    uint256 _rewardRatePerSecond
    ) {
    stakingToken = IERC20(_stakingToken); //用户必须质押参与的 ERC-20 代币
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
     //受到 nonReentrant 修饰符的保护，以阻止重入攻击(因为它涉及转移代币)
    require(amount > 0, "Cannot stake 0");

    updateRewards(msg.sender);
    //在接受新存款之前，我们计算并存储用户到目前为止已经赚取的任何待处理奖励

    stakingToken.transferFrom(msg.sender, address(this), amount); //从用户的钱包拉入质押代币到合约中
    stakers[msg.sender].stakedAmount += amount;

    emit Staked(msg.sender, amount);
    }
    //     取消质押代币并可选择领取奖励
    function unstake(uint256 amount) external nonReentrant {
    require(amount > 0, "Cannot unstake 0");
    require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked"); //用户不能取消质押超过他们最初存入的数量

    updateRewards(msg.sender);

    stakers[msg.sender].stakedAmount -= amount;
    stakingToken.transfer(msg.sender, amount);

    emit Unstaked(msg.sender, amount);
    }
    ////     领取累积的奖励
    function claimRewards() external nonReentrant {
    updateRewards(msg.sender);
    //读取用户当前欠的奖励数量(存储为他们的 rewardDebt)
    uint256 reward = stakers[msg.sender].rewardDebt;
    require(reward > 0, "No rewards to claim");
    require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");
    //重置用户的奖励债务
    stakers[msg.sender].rewardDebt = 0;
    // 将奖励转给用户
    rewardToken.transfer(msg.sender, reward);
    //发出奖励领取事件
    emit RewardClaimed(msg.sender, reward);
    }

    function emergencyWithdraw() external nonReentrant { //安全第一 — 即使紧急退出也受到重入攻击的保护
    uint256 amount = stakers[msg.sender].stakedAmount;
    require(amount > 0, "Nothing staked");
    //重置所有用户信息
    stakers[msg.sender].stakedAmount = 0;
    stakers[msg.sender].rewardDebt = 0;
    stakers[msg.sender].lastUpdate = block.timestamp; //更新他们的 lastUpdate 到当前时间(即使他们正在退出

    stakingToken.transfer(msg.sender, amount);

    emit EmergencyWithdraw(msg.sender, amount);
    }
    //管理员可以补充奖励代币
    function refillRewards(uint256 amount) external onlyOwner {
    rewardToken.transferFrom(msg.sender, address(this), amount); //将新奖励拉入合约

    emit RewardRefilled(msg.sender, amount);
    }
    //更新质押者的奖励
    function updateRewards(address user) internal {
    StakerInfo storage staker = stakers[user]; //从存储中获取用户的质押者数据,所做的任何更改都将立即反映在链上 storage这个函数的目标是修改用户的状态
    if (staker.stakedAmount > 0) {
        //计算过了多少时间
        uint256 timeDiff = block.timestamp - staker.lastUpdate;
        //根据小数位数设置奖励乘数 ** 10^X
        uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
        uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
        //乘以过去的时间 × 奖励率 × 质押金额,除以奖励乘数以调整小数位数
        staker.rewardDebt += pendingReward;
    }
    //更新时间
    staker.lastUpdate = block.timestamp;
    }

    ///     查看待处理奖励而不领取
    function pendingRewards(address user) external view returns (uint256) {
    StakerInfo memory staker = stakers[user]; //将用户的质押信息加载到内存中(而不是存储) memory：值传递（只读副本）

    uint256 pendingReward = staker.rewardDebt;
    //如果他们有质押的代币，添加新奖励

    if (staker.stakedAmount > 0) {
        uint256 timeDiff = block.timestamp - staker.lastUpdate;
        uint256 rewardMultiplier = 10 ** stakingTokenDecimals;
        //计算用户在那段时间内赚了多少奖励
        pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;
    }
    return pendingReward;
    }
    /// 查看质押代币小数位数
    function getStakingTokenDecimals() external view returns (uint8) {
    return stakingTokenDecimals; //简单返回小数位数
    }




}