// 区块链存钱生利息机器/区块链利息银行：1开银行→2用户存钱→3时间流逝→4用户领利息→5用户取本金→6紧急逃生→7管理员补奖励池
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";   //导入ERC20的规则，以便处理质押代币和奖励代币
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";   //防止重入攻击
import "@openzeppelin/contracts/utils/math/SafeCast.sol"; // 如果需要使用 SafeCast(一般是拿来做“安全类型转换”的),比如把 uint256 转成更小的数字类型时，避免乱截断

// 用于获取 ERC-20 元数据(小数位数)的接口——“下面要写一个接口，专门用来读 ERC-20 代币的一些额外信息，比如小数位数。”
interface IERC20Metadata is IERC20 {   //定义了新接口IERC20Metadata(基于IRC20扩展)，下面要写一个接口，专门用来读 ERC-20 代币的一些额外信息，比如小数位数。(奖励计算会用到精度如USDC小数位是6，很多别的币是 18)
    function decimals() external view returns (uint8);   //定义一个函数：decimals(),问代币合约“你有几位小数？”返回值是 uint8，也就是一个比较小的整数。
    function name() external view returns (string memory);   //读取代币名字。比如 "USD Coin" 这种
    function symbol() external view returns (string memory);   //读取代币符号。比如 "USDC"、"ETH" 这种。
}

// 收益耕作平台:支持：质押代币、按时间赚奖励、紧急提取、管理员补奖励池
// 质押代币以随时间赚取奖励,可选紧急提取和管理员补充
contract YieldFarming is ReentrancyGuard {   //表示这个合约继承了防重入保护,相当于这个“存钱生利息机器”自带防盗锁。
    using SafeCast for uint256;   //“让 uint256 这个类型可以使用 SafeCast 的方法。”(先预留了安全转换能力)

    IERC20 public stakingToken;   //“这是存钱时要存进去的那种币。”(用户要拿来质押的代币)
    IERC20 public rewardToken;   //定义奖励代币：系统以后发奖励时，发的是这种币

    uint256 public rewardRatePerSecond; // 每秒分配的奖励(类似奖励水龙头)

    address public owner;

    uint8 public stakingTokenDecimals; // 存储质押代币的小数位数

    struct StakerInfo {   //“每个质押用户的信息盒子”——每个用户都会有一份这样的资料
        uint256 stakedAmount;   //记录这个用户质押了多少币。也就是“本金有多少”。
        uint256 rewardDebt;   //记录这个用户已经累计、但还没领走的奖励。“待领取奖励余额”不是欠钱，是系统替你记着“你有多少奖励还没拿”。
        uint256 lastUpdate;   //记录上一次更新时间戳。
    }

    mapping(address => StakerInfo) public stakers;    //每个地址，对应一份质押信息。

    event Staked(address indexed user, uint256 amount);   //有人质押了，记录谁质押、质押多少
    event Unstaked(address indexed user, uint256 amount);   //有人取消质押了
    event RewardClaimed(address indexed user, uint256 amount);   //有人领取奖励了
    event EmergencyWithdraw(address indexed user, uint256 amount);   //有人紧急提取了本金
    event RewardRefilled(address indexed owner, uint256 amount);    //管理员给奖励池补币了

    modifier onlyOwner() {   //定义一个“门禁规则”：只有管理员可以用。
        require(msg.sender == owner, "Not the owner");   //检查当前调用人是不是管理员。
     _;}   //“前面的检查通过后，继续执行真正的函数内容。”

    constructor(   //构造函数，部署合约时只执行一次。部署时要传以下三个参数：
        address _stakingToken,   //质押代币地址
        address _rewardToken,   //奖励代币地址
        uint256 _rewardRatePerSecond   //每秒奖励速率
    ) {   //这个系统一出生，就要先把“存什么币、奖励发什么币、每秒发多快”设好
        stakingToken = IERC20(_stakingToken);   //把传进来的质押代币地址，保存成 ERC-20 对象。
        rewardToken = IERC20(_rewardToken);   //把奖励代币地址保存起来
        rewardRatePerSecond = _rewardRatePerSecond;   //保存每秒奖励速率
        owner = msg.sender;

        // 尝试获取质押代币的小数位数
        try IERC20Metadata(_stakingToken).decimals() returns (uint8 decimals) {   //“我试着去问这个代币：你的小数位是多少？”
            stakingTokenDecimals = decimals;   //成功读到了小数位，就保存下来。比如读到 6，就存 6；读到 18，就存 18
        } catch (bytes memory) {   //如果刚才那次读取失败，就会走这里。“这个代币可能不支持 decimals()，那我就走备用方案。”
            stakingTokenDecimals = 18; // 如果获取失败,默认为 18 位小数(如果代币实际不是 18 位，而又没法读到 decimals()，那奖励计算可能会不准)
        }
    }

    // 质押代币以开始赚取奖励
    function stake(uint256 amount) external nonReentrant {   //amount，就是你要质押多少代币
        require(amount > 0, "Cannot stake 0");   //不能质押0

        updateRewards(msg.sender);    //在你这次质押前，先把你之前那一段时间该得的奖励算清楚，记到账上。
        //Q:为什么必须先算?  A:因为如果你原来已经质押了 100 个币，过了 10 天，你现在又来加仓 50 个币，那系统必须先把“前面那 10 天，按 100 个币算出来的奖励”记好，不能让后面新加的 50 个币假装也在前 10 天里存在过。所以这一句是在做“先结旧账，再记新账”。

        stakingToken.transferFrom(msg.sender, address(this), amount);   //“把用户的钱，从用户钱包转到合约里。” transfrom：合约主动从用户那里取币
        stakers[msg.sender].stakedAmount += amount;    //把用户的质押数量加上这次新存入的数量。

        emit Staked(msg.sender, amount);   //广播事件：“某某用户质押了多少。”
    }

    // 取消质押代币并可选择领取奖励“取消质押时，会先把奖励记账好，你之后可以再领。”
    function unstake(uint256 amount) external nonReentrant {   //untake:用户可以取回自己质押的一部分或全部本金
        require(amount > 0, "Cannot unstake 0");   //取回数量不能是0
        require(stakers[msg.sender].stakedAmount >= amount, "Not enough staked");   //要取的不能超过自己存进去的量

        updateRewards(msg.sender);   //“你在取钱之前，先把到这一秒为止的奖励算清楚。”

        stakers[msg.sender].stakedAmount -= amount;   //把你的质押本金减掉要提取的数量。
        stakingToken.transfer(msg.sender, amount);   //把质押代币从合约转回给用户。“把本金退给你”

        emit Unstaked(msg.sender, amount);    //广播事件：某用户取消质押了多少。
    }

    // 领取累积的奖励
    function claimRewards() external nonReentrant {   //定义领取奖励函数
        updateRewards(msg.sender);   //先把你到现在这一刻的奖励全部算出来，记到账上。

        uint256 reward = stakers[msg.sender].rewardDebt;   //把你当前累计的待领取奖励，拿出来放进一个临时变量 reward 里
        require(reward > 0, "No rewards to claim");   //如果没有奖励，就不让领
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");   //检查合约里奖励币够不够

        stakers[msg.sender].rewardDebt = 0;   //在真正转奖励之前，先把用户的奖励余额清零。(安全写法的一种思路)
        rewardToken.transfer(msg.sender, reward);   //把奖励币发给用户

        emit RewardClaimed(msg.sender, reward);   //广播：某用户领取了多少奖励
    }

    // 紧急取消质押而不领取奖励
    function emergencyWithdraw() external nonReentrant {   //定义紧急提取函数
        uint256 amount = stakers[msg.sender].stakedAmount;    //先把用户当前质押的本金数量记下来
        require(amount > 0, "Nothing staked");   //如果你根本没质押，那就没有东西可以紧急提取。

        stakers[msg.sender].stakedAmount = 0;   //把你的质押本金记为 0
        stakers[msg.sender].rewardDebt = 0;   //把你的待领取奖励也直接清零。(紧急退出的代价)
        stakers[msg.sender].lastUpdate = block.timestamp;   //更新时间也重设为当前时间。“从这一刻起，你这份旧质押记录彻底清空结束。”

        stakingToken.transfer(msg.sender, amount);   //把本金退给用户

        emit EmergencyWithdraw(msg.sender, amount);   //广播：某用户紧急提取了多少本金
    }

    // 管理员可以补充奖励代币
    function refillRewards(uint256 amount) external onlyOwner {   //只有owner可调用
        rewardToken.transferFrom(msg.sender, address(this), amount);   //把管理员自己的奖励代币，从管理员钱包转到合约里。

        emit RewardRefilled(msg.sender, amount);   //广播：管理员补充了多少奖励币。
    }

    //【核心】更新质押者的奖励
    function updateRewards(address user) internal {   //internal：只能内部调用(内部记账员)
        StakerInfo storage staker = stakers[user];   //storage:“直接连到链上真正存储的那份数据本体。”不是临时副本，而是真身。

        if (staker.stakedAmount > 0) {   //只有在用户真的有质押本金时，才需要计算奖励。
            uint256 timeDiff = block.timestamp - staker.lastUpdate;   //计算时间差：现在事件-上次更新事件
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;   //计算精度倍率，如果质押代币是18位小数，即rewardMultiplier = 10^18(作用:让奖励计算时，不会因为代币底层数字很大而直接失真)
            uint256 pendingReward = (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;   //本次新增奖励 = 时间差 × 每秒奖励速率 × 质押数量 ÷ 精度倍率
            staker.rewardDebt += pendingReward;    //把这次新算出来的奖励，加到原本的待领取奖励里
        }    //如果有质押，就完成奖励更新。

        staker.lastUpdate = block.timestamp;   //无论有没有质押，这里都把“上次更新时间”改成当前时间。
    }

    // 查看待处理奖励而不领取
    function pendingRewards(address user) external view returns (uint256) {   //返回这个用户现在应该有多少待领取奖励
        StakerInfo memory staker = stakers[user];   //把用户数据取出来

        uint256 pendingReward = staker.rewardDebt;   //先从已经记账好的奖励开始

        if (staker.stakedAmount > 0) {   //如果用户现在还有质押本金，就继续把“从上次更新时间到现在”这一段也估算进去
            uint256 timeDiff = block.timestamp - staker.lastUpdate;   //算时间差
            uint256 rewardMultiplier = 10 ** stakingTokenDecimals;    //算精度倍率
            pendingReward += (timeDiff * rewardRatePerSecond * staker.stakedAmount) / rewardMultiplier;   //把“这段还没正式记账、但理论上已经赚到的奖励”也加上去；pendingReward += ...不是改链上状态，只是“帮你预览一下如果现在领取，大概能拿多少”
        }   //如果有质押，就完成预览计算

        return pendingReward;   //把算出来的待领取奖励返回出去
    }

    // 查看质押代币小数位数
    function getStakingTokenDecimals() external view returns (uint8) {
        return stakingTokenDecimals;   //把小数位数返回出去
    }
}




// stakingToken:用户拿来“存进去”的币。比如你拿 USDC、ABC、HER 这种代币来质押。
// rewardToken: 系统发给你的“奖励币”。
// stake：存进去、锁进去、参加挖矿。unstake:把之前存进去的币拿回来。
// rewardDebt:不是“欠债”，“系统帮你记账：你目前已经累计了多少待领取奖励。”
// try ... returns ...，表示：如果成功，就拿到返回值; 如果失败，也别整个合约崩掉，可以走 catch
// 先做旧账，再改本金：因为用户的本金一旦变化，奖励计算规则也会变。奖励计算规则也会变。这就像你存银行时，先把上个月利息结完，再改新的存款额。
// 奖励不是一直自动发，而是“按需结算”:这份代码不是每秒钟主动给所有人转账。那样太浪费 gas，也不现实。做法是：平时只记规则，当你 stake / unstake / claim 时，再根据时间差把奖励补算出来("懒结算"思路)
// 奖励公式和“时间 + 本金”有关：核心逻辑→奖励 = 时间 × 速率 × 质押数量 ÷ 精度倍率。所以质押越多，奖励越多，时间越多，奖励越多
// 紧急提取是安全出口：emergencyWithdraw()的设计理念是“就算奖励系统出问题，至少用户能先把本金拿走。”(本金安全通常优先级更高)



