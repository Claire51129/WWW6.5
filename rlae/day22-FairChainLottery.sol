
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
// fulfillRandomWords 的特殊函数
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
//构造和格式化我们发送给 Chainlink 的随机性请求

contract FairChainLottery is VRFConsumerBaseV2Plus {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING } //enumeration（枚举） //- 我们只在 `lotteryState == OPEN` 时允许新玩家参与,我们只在状态为 `CLOSED` 时开始新一轮,我们只在 `CALCULATING` 状态时选择赢家
    LOTTERY_STATE public lotteryState; //LOTTERY_STATE: 这是自定义的枚举类型（Enum）,lotteryState() for look up
    address payable[] public players; //存储本轮加入的每个人
    address public recentWinner; //记住上一轮谁赢了
    uint256 public entryFee;

    uint256 public subscriptionId; //LINK 代币为其充值以支付预言机服务
    bytes32 public keyHash; //想要运行哪个 Chainlink 预言机任务
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3; //设置了 Chainlink 在生成随机数之前等待多少个区块确认,增加了安全性，但也增加了轻微的延迟。
    uint32 public numWords = 1; //想要多少个随机数 winner numbers
    uint256 public latestRequestId; //随机性订单的票号
    constructor(
    address vrfCoordinator, //要部署到的区块链上 Chainlink VRF 协调器的地址
    uint256 _subscriptionId, //你的 Chainlink 订阅 ID（用于支付 VRF 请求
    bytes32 _keyHash,
    uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
    subscriptionId = _subscriptionId;
    keyHash = _keyHash;
    entryFee = _entryFee;
    lotteryState = LOTTERY_STATE.CLOSED; //默认将 lotteryState 设置为 CLOSED,所有者可以调用 startLottery() 来打开大门。
    }
    function enter() public payable {
    require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open"); //只允许人们在彩票处于 OPEN 状态时进入
    require(msg.value >= entryFee, "Not enough ETH"); //检查玩家是否已经支付了至少所需的最低 ETH
    players.push(payable(msg.sender));//检查玩家是否已经支付了至少所需的最低 ETH
    }
    function startLottery() external onlyOwner { //只有部署合约的人可以调用此函数
    require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet"); //不会在另一轮已经在进行时开始一轮
    lotteryState = LOTTERY_STATE.OPEN;
    }
    function endLottery() external onlyOwner {
    require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
    lotteryState = LOTTERY_STATE.CALCULATING;//将状态翻转为 CALCULATING

    VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
        keyHash: keyHash, //使用哪个随机性任务
        subId: subscriptionId, //谁在付款
        requestConfirmations: requestConfirmations, //等待多少确认
        callbackGasLimit: callbackGasLimit, //响应时使用多少 gas
        numWords: numWords, //我们想要多少个随机数（在这种情况下，只有 1）
        extraArgs: VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: true}) //你选择使用链的原生代币（如 Sepolia ETH）来支付手续费，而不是使用传统的 LINK 代币
        )
    });

    latestRequestId = s_vrfCoordinator.requestRandomWords(req); //将请求发送到 Chainlink VRF
    }
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        //为什么代码里常省略变量名：如果你不在意这是哪个订单（比如你的合约一次只处理一个请求），你可以不给它起名字以节省微量的 Gas。
        //uint256 (requestId) uint256[] calldata randomWords (随机数数组),calldata：这是一种存储类型，告诉 Solidity 这些数据是直接从调用数据中读取的，不可修改且最省 Gas
    require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

    uint256 winnerIndex = randomWords[0] % players.length;
    address payable winner = players[winnerIndex];
    recentWinner = winner; //存储赢家的地址以供参考，可能在 UI 中显示或稍后记录

    players = new address payable[](0); // new address payable[]: 这是在内存或状态变量中创建一个新的地址数组,设置为 0 意味着创建一个没有任何元素的新数组。
    lotteryState = LOTTERY_STATE.CLOSED;

    (bool sent, ) = winner.call{value: address(this).balance}("");
    require(sent, "Failed to send ETH to winner");
    }
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }



}