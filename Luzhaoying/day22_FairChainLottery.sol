// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//这是 Chainlink 提供的一个基础合约。我们从它继承，作为回报，我们得到一个名为 fulfillRandomWords 的特殊函数，当随机数准备好时，Chainlink 会自动调用它
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
//这是一个辅助库，它给我们提供了一种简单的方式来构造和格式化我们发送给 Chainlink 的随机性请求
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {
    //enum 是 enumeration（枚举）的缩写，在 Solidity 中，它是一种创建变量可以取的命名状态列表的方法
    //此处的枚举值为3种：
    //- `OPEN` —— 彩票正在进行，**玩家可以参与**
    // `CLOSED` —— 彩票关闭，玩家不可参与
    // `CALCULATING` —— 彩票目前**正在向 Chainlink 请求随机数**，在我们获得结果之前**没有人可以参与或重启游戏**。
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;
    //玩家跟踪
    //`players` 存储本轮加入的每个人。
    //`recentWinner` 记住上一轮谁赢了。
    //`entryFee` 设置某人必须支付多少 ETH 才能加入
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    //Chainlink VRF 配置
    //你的 Chainlink 账户 ID,与你的 Chainlink 订阅绑定，你用 LINK 代币为其充值以支付预言机服务
    uint256 public subscriptionId;
    //keyHash作为唯一标识符，确保你连接到适合你需求的正确预言机设置
    bytes32 public keyHash;
    //在履行请求时可以使用至多100,000个 gas,100,000 通常是简单逻辑（如选择赢家）的良好安全默认值
    uint32 public callbackGasLimit = 100000;
    //Chainlink 在生成随机数之前等待多少个区块确认，3这样的值是速度和安全性之间的可靠平衡
    uint16 public requestConfirmations = 3;
    //这告诉 Chainlink 你在一次请求中想要多少个**随机数**。我们只是在这里选择一个赢家，所以 `1` 就足够了
    uint32 public numWords = 1;
    //每次发出随机性请求时，Chainlink 都会给你一个请求 ID
    uint256 public latestRequestId;

    //构造函数 —— 设置游戏室
    constructor(
        address vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) //这是你要部署到的区块链上 Chainlink VRF 协调器的地址
    {
        subscriptionId = _subscriptionId;//这是你的 Chainlink 订阅 ID（用于支付 VRF 请求）
        keyHash = _keyHash;//这定义了 Chainlink 应该使用哪个随机性任务
        entryFee = _entryFee;//这设置了玩家必须支付多少 ETH 才能参与每轮彩票
        lotteryState = LOTTERY_STATE.CLOSED;
    }
//构造函数：售票亭，允许区块链上的任何用户参与彩票，只要他们遵守规则
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
    }
//开始游戏
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }
//结束游戏
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;
//构建请求,告诉 Chainlink 它需要知道的一切：
//- 使用哪个随机性任务（`keyHash`）
//- 谁在付款（`subscriptionId`）
//- 等待多少确认
//- 响应时使用多少gas
//- 我们想要多少个随机数（在这种情况下，只有 `1`）
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });
//发送请求
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }
//一旦 Chainlink 收到我们的请求并完成其密码学魔法，它会通过调用此函数直接将结果发送回我们的合约
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
//安全检查  
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");
//选择赢家
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
//宣布赢家       
        recentWinner = winner;
//为下一轮重置
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
//发送奖金
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }
//返回当前玩家列表
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}
