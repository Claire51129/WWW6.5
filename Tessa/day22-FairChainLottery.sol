
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 调用一个“官方随机数API”——帮助和ChainlinkVRF通信；自动验证随机数是否真是
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

// 引入一个“工具库”——构造请求随机数的参数
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {   //表示继承自VRFConsumerBaseV2Plus —— 这就是赋予我们的合约从 Chainlink 接收随机数并在我们的逻辑中使用它们的能力。
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }   //(重要)定义一个“状态机”，包含正在进行、不活跃(无人参与)、正在向Chainlink请求随机数，在我们获得结果之前没有人可以参与或重启游戏。
    LOTTERY_STATE public lotteryState;    //当前状态变量

    address payable[] public players;   //玩家数组：钱包地址+可以收钱(重要);players存储本轮加入的每个人
    address public recentWinner;    //最近中奖的人;recentWinner记住上一轮谁赢了
    uint256 public entryFee;    //参与费用；entryFee设置某人必须支付多少ETH才能加入

    // 【重点】Chainlink VRF 配置——连接随机性引擎
    // 当向 Chainlink 请求一个随机数时，我们不只是说要一些随机的东西，而是必须非常具体的说明自己想要什么，以下配置变量就是为了说明此：    
    uint256 public subscriptionId;   //Chainlink订阅ID(你要充值用)；subscriptionId就像你的 Chainlink 账户 ID —— 它与你的 Chainlink 订阅绑定，你用 LINK 代币为其充值以支付预言机服务。每次发出随机性请求时，LINK 都会从你的订阅中扣除。这个 ID 告诉 Chainlink 协调器“记在我账上”
    bytes32 public keyHash;   //指定随机数"密钥"，类似选择一个随机数服务节点；keyHash是一个唯一标识符，它确保你连接到适合你需求的正确预言机设置，它标识了你想要运行哪个 Chainlink 预言机任务。可以想象 Chainlink 有许多不同的"任务" —— 每个任务由具有不同配置的不同预言机提供支持（有些更快，有些更去中心化等）。“使用 VRF 服务的这个特定配置”
    uint32 public callbackGasLimit = 100000;   //回调函数最多要多少gas?(PS:VRF回调要链上执行→需限制gas);Chainlink 必须调用你的 fulfillRandomWords() 函数来传递随机数。
    uint16 public requestConfirmations = 3;   //等待3个区块确认(保证安全性:防止区块回滚攻击)——设置了 Chainlink 在生成随机数之前等待多少个区块确认。
    uint32 public numWords = 1;    //告诉chainlink要几个随机数(这里只要1个) 意味着在这里选择一个赢家
    uint256 public latestRequestId;   //记录最近请求ID(方便追踪)——类似于随机性订单票号

    constructor(    //构造函数——初始化合约时传入参数（constructor是特殊函数，只在合约首次部署时运行一次）
        address vrfCoordinator,    //这是你要部署到的区块链上 Chainlink VRF 协调器的地址。它充当接收随机性请求并返回结果的中间人。
        uint256 _subscriptionId,   //这是你的 Chainlink 订阅 ID（用于支付 VRF 请求）。
        bytes32 _keyHash,    //定义了 Chainlink 应该使用哪个随机性任务。
        uint256 _entryFee    //设置了玩家必须支付多少 ETH 才能参与每轮彩票。
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {   //调用母类构造函数——告诉合约VRF Coordinator地址是谁
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;   //保存参数；将入场费存储为状态变量，以便可以在 enter() 函数中重用。
        lotteryState = LOTTERY_STATE.CLOSED;   //初始状态关闭(防止一部署就能参与-不安全)
    }    //保存部署期间传递给我们的 Chainlink 配置。

    // 用户参与抽奖功能
    function enter() public payable {   //允许用户发送ETH
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");   //必须是open状态才能进入(防作弊)
        require(msg.value >= entryFee, "Not enough ETH");   //必须付够钱；msg.value 是随交易一起发送的 ETH 数量。
        players.push(payable(msg.sender));    //如所有检查都通过，我们将玩家添加到列表中
    }    //我们用 payable(...) 包装 msg.sender，因为我们计划稍后可能会向这个地址发送 ETH（如果他们赢了）。Solidity 需要我们将其标记为 payable，以便向其转移资金。

    // 抽奖开始功能
    function startLottery() external onlyOwner {   //只有owner能调用该功能
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");   //检查是否处于关闭状态(必须是关闭状态)
        lotteryState = LOTTERY_STATE.OPEN;   //开启抽奖
    }

    // 结束抽奖并请求随机性功能
    function endLottery() external onlyOwner {   //管理员/owner结束;该处为手动调用调用 endLottery() 来发送随机性请求
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;   //进入"计算中奖人"；一旦我们结束了这一轮，我们就将状态翻转为 CALCULATING。这表明我们正在选择赢家的过程中，现在没有新玩家可以进入。

        //【魔法】创建一个VRF请求结构体：制作一个要发送给 Chainlink 的随机性请求。
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,   //告诉chainlink要几个随机性任务
            subId: subscriptionId,   //谁在付款
            requestConfirmations: requestConfirmations,   //等待多少确认
            callbackGasLimit: callbackGasLimit,    //响应时最多使用多少gas
            numWords: numWords,    //↑配置参数(前面定义的)；我们想要多少随机数(这种情况下只有1)
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})   //用原生代币支付(如AVAX)
            )
        });

        latestRequestId = s_vrfCoordinator.requestRandomWords(req);   //向Chainlink发请求，返回requestId
    }   //流程1>你请求随机数、2>Chainlink生成、3>回调你的函数(无需手动调用下一个函数)

    // 【重要】VRF回调函数(自动调用、不可手动调用)
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");   //确保状态正确(处于选择赢家的过程中)

        //使用 Chainlink 提供的随机数并应用**模运算符（%）**以确保它映射到玩家索引之一。
        uint256 winnerIndex = randomWords[0] % players.length;   //核心逻辑：随机数%玩家数→得到赢家索引(确保结果在数组范围内)
        address payable winner = players[winnerIndex];   //找到赢家
        recentWinner = winner;    //保存赢家(存储赢家的地址以供参考，可能在 UI 中显示或稍后记录)

        players = new address payable[](0);   //清空赢家(为下一轮准备)
        lotteryState = LOTTERY_STATE.CLOSED;    //抽奖结束

        (bool sent, ) = winner.call{value: address(this).balance}("");   //把所有钱转给赢家；address(this).balance指合约里的全部钱
        require(sent, "Failed to send ETH to winner");   //确保转账成功
    }

    // 查询玩家列表功能
    function getPlayers() external view returns (address payable[] memory) {   //查询玩家列表
        return players;   //返回当前玩家列表。对前端应用程序或浏览器很有用。
    }
}

// Q: 为什么VRF重要? A: 没有VRF的话项目方可以用block.timestamp等函数作弊；有VRF→数学保证公平，无法操控
// Chainlink VRF —— 一个在链上工作的可信随机性来源。作用：可证明公平、完全自动化、不可能被操纵
// VRFConsumerBaseV2Plus:Chainlink 提供的一个基础合约。我们从它继承，作为回报，我们得到一个名为 fulfillRandomWords 的特殊函数，当随机数准备好时，Chainlink 会自动调用它。可以把它看作是随机数的"回调"插槽。
// VRFV2PlusClient: 这是一个辅助库，它给我们提供了一种简单的方式来构造和格式化我们发送给 Chainlink 的随机性请求。它让我们可以配置以下内容：我们想要多少个随机数、回调使用多少 gas、使用哪个 Chainlink 任务（通过 keyHash）
// VRFConsumerBaseV2Plu和VRFV2PlusClient这两个部分是构成链上随机性的直接链接，没有他们，将无法安全接触外部世界(import的两个合约)
// enum：enumeration（枚举）的缩写，在 Solidity 中，它是一种创建变量可以取的命名状态列表的方法。
// lotteryState变量是合约的大脑 —— 它帮助我们管理游戏流程并在正确的时间执行正确的规则。(具备安全性，防止1>人们在选择赢家期间偷偷溜进来,2>在另一轮中间意外开始新一轮,3>重复的随机性请求（这会很昂贵且混乱）)
// 当lotteryState == OPEN 时：允许新玩家参与
// 当lotteryState == CLOSED 时：开始新一轮
// 当lotteryState == CALCULATING 时选择赢家







