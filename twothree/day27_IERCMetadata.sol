// SPDX-License-Identifier: MIT                                   
pragma solidity ^0.8.20;                                         

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";         // 引入标准代币接口
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";       // 引入安全锁，防止重复攻击
import "@openzeppelin/contracts/utils/math/SafeCast.sol";        // 引入安全数字转换工具

interface IERC20Metadata is IERC20 {                             // 扩展接口，获取代币名字、小数位
    function decimals() external view returns (uint8);          // 获取代币小数点位数
    function name() external view returns (string memory);      // 获取代币名字
    function symbol() external view returns (string memory);    // 获取代币符号
}

// 合约名字：挖矿赚钱平台
contract YieldFarming is ReentrancyGuard {                       // 定义挖矿合约，带安全防护
    using SafeCast for uint256;                                  // 使用安全数字工具
    IERC20 public stakingToken;                                  // 用来质押的代币（存这个）
    IERC20 public rewardToken;                                   // 用来奖励的代币（赚这个）
    uint256 public rewardRatePerSecond;                          // 每秒发多少奖励
    address public owner;                                        // 合约管理员
    uint8 public stakingTokenDecimals;                           // 质押代币的小数点位数
    struct StakerInfo {                                          // 每个用户的挖矿信息
        uint256 stakedAmount;                                    // 质押了多少钱
        uint256 rewardDebt;                                      // 待领取的奖励
        uint256 lastUpdate;                                      // 最后一次更新时间
    }

    mapping(address => StakerInfo) public stakers;               // 按地址保存每个用户信息

    event Staked(address indexed user, uint256 amount);          // 事件：用户质押
    event Unstaked(address indexed user, uint256 amount);        // 事件：用户取消质押
    event RewardClaimed(address indexed user, uint256 amount);    // 事件：领取奖励
    event EmergencyWithdraw(address indexed user, uint256 amount); // 事件：紧急取出
    event RewardRefilled(address indexed owner, uint256 amount); // 事件：管理员补充奖励

    modifier onlyOwner() {                                       // 只有管理员能用
        require(msg.sender == owner, "Not the owner");          // 检查是不是管理员
        _;                                                        // 执行函数
    }

    constructor(                                                  // 部署合约时设置
        address _stakingToken,                                   // 质押代币地址
        address _rewardToken,                                    // 奖励代币地址
        uint256 _rewardRatePerSecond                             // 每秒奖励速度
    ) {
        stakingToken = IERC20(_stakingToken);                    // 设置质押代币
        rewardToken = IERC20(_rewardToken);                      // 设置奖励代币
        rewardRatePerSecond = _rewardRatePerSecond;            // 设置奖励速度
        owner = msg.sender;                                      // 部署者是管理员

        // 尝试获取小数位数
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {
            stakingTokenDecimals = decimals;                     // 获取代币小数点
        } catch (bytes memory) {
            stakingTokenDecimals = 18;                           // 获取不到默认18位
        }
    }

    //质押代币以开始赚取奖励
    function stake(uint256 amount) external nonReentrant {       // 质押存钱挖矿
        require(amount > 0, "Cannot stake 0");                  // 不能存0

        updateRewards(msg.sender);                              // 更新奖励

        stakingToken.transferFrom(msg.sender, address(this), amount); // 转钱进合约
        stakers[msg.sender].stakedAmount += amount;             // 增加质押数量

        emit Staked(msg.sender, amount);                        // 广播：质押成功
    }

    //取消质押代币并可选择领取奖励
    function unstake(uint256 amount) external nonReentrant {    // 取消质押取钱
        require(amount > 0, "Cannot unstake 0");               // 不能取0
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked"); // 钱够不够

        updateRewards(msg.sender);                              // 更新奖励

        stakers[msg.sender].stakedAmount -= amount;             // 减少质押数量
        stakingToken.transfer(msg.sender, amount);              // 把钱转回用户

        emit Unstaked(msg.sender, amount);                      // 广播：取消质押
    }

    //领取累积的奖励
    function claimRewards() external nonReentrant {             // 领取赚的奖励
        updateRewards(msg.sender);                              // 先更新奖励

        uint256 reward = stakers[msg.sender].rewardDebt;        // 可领取奖励
        require(reward > 0, "No rewards to claim");            // 有奖励才能领
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance"); // 合约钱够不够

        stakers[msg.sender].rewardDebt = 0;                     // 奖励清零
        rewardToken.transfer(msg.sender, reward);               // 转奖励给用户

        emit RewardClaimed(msg.sender, reward);                 // 广播：奖励已领
    }

    //紧急取消质押而不领取奖励
    function emergencyWithdraw() external nonReentrant {        // 紧急取出（不要奖励）
        uint256 amount = stakers[msg.sender].stakedAmount;      // 用户质押的钱
        require(amount > 0, "Nothing staked");                 // 有钱才能取

        stakers[msg.sender].stakedAmount = 0;                   // 质押清零
        stakers[msg.sender].rewardDebt = 0;                     // 奖励清零
        stakers[msg.sender].lastUpdate = block.timestamp;       // 更新时间

        stakingToken.transfer(msg.sender, amount);              // 把本金转回

        emit EmergencyWithdraw(msg.sender, amount);             // 广播：紧急取出
    }

    //管理员可以补充奖励代币
    function refillRewards(uint256 amount) external onlyOwner { // 管理员加奖励
        rewardToken.transferFrom(msg.sender, address(this), amount); // 转奖励进合约

        emit RewardRefilled(msg.sender, amount);                // 广播：奖励已补充
    }

    //更新质押者的奖励
    function updateRewards(address user) internal {             // 内部函数：计算奖励
        StakerInfo storage staker = stakers[user];              // 找到用户信息

        if (staker.stakedAmount > 0) {                          // 如果用户质押了钱
            uint256 timeDiff = block.timestamp - staker.lastUpdate; // 距离上次更新时间
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals; // 小数点换算
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier; // 算奖励
            staker.rewardDebt += pendingReward;                 // 增加待领奖励
        }

        staker.lastUpdate = block.timestamp;                    // 更新最后时间
    }

    //查看待处理奖励而不领取
    function pendingRewards(address user) external view returns (uint256) { // 查询能赚多少
        StakerInfo memory staker = stakers[user];              // 获取用户信息

        uint256 pendingReward = staker.rewardDebt;             // 已算好的奖励

        if (staker.stakedAmount > 0) {                         // 如果正在挖矿
            uint256 timeDiff = block.timestamp - staker.lastUpdate; // 时间差
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals; // 小数点换算
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier; // 总奖励
        }

        return pendingReward;                                  // 返回可领奖励
    }

    //查看质押代币小数位数
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;                           // 返回小数点位数
    }
}
//这是一个挖矿赚钱合约
//您存进去代币 → 自动按秒赚奖励
//随时可以取本金、领奖励
//出事可以紧急取出本金