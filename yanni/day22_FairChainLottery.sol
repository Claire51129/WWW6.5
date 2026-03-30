// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 Chainlink VRF 基类（负责安全回调验证）
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

// 引入 VRF 请求结构体工具库
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 彩票合约，继承 VRF 功能
contract FairChainLottery is VRFConsumerBaseV2Plus {

    // 彩票状态枚举
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }

    LOTTERY_STATE public lotteryState; // 当前状态

    address payable[] public players; // 玩家列表（可以收钱）
    address public recentWinner;      // 最近的赢家

    uint256 public entryFee;          // 参与费用

    // ===== Chainlink VRF 配置 =====
    uint256 public subscriptionId;    // 订阅ID（用于支付随机数费用）
    bytes32 public keyHash;           // 指定随机数服务
    uint32 public callbackGasLimit = 100000; // 回调函数最大 gas
    uint16 public requestConfirmations = 3;  // 等待区块确认数
    uint32 public numWords = 1;       // 要几个随机数

    uint256 public latestRequestId;   // 最近请求的ID（用于追踪）

    // ===== 构造函数 =====
    constructor(
        address vrfCoordinator,   // Chainlink VRF 协调器地址
        uint256 _subscriptionId,  // 订阅ID
        bytes32 _keyHash,         // keyHash
        uint256 _entryFee         // 入场费
    )
        // 调用父合约构造函数（必须）
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        // 把参数存入链上（storage）
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;

        // 初始状态为关闭
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // ===== 玩家参与 =====
    function enter() public payable {

        // 必须是 OPEN 状态
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");

        // 必须支付足够 ETH
        require(msg.value >= entryFee, "Not enough ETH");

        // 把玩家加入数组
        players.push(payable(msg.sender));
    }

    // ===== 开始彩票（只有管理员）=====
    function startLottery() external onlyOwner {

        // 只能从 CLOSED 开始
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");

        lotteryState = LOTTERY_STATE.OPEN;
    }

    // ===== 结束彩票并请求随机数 =====
    function endLottery() external onlyOwner {

        // 必须是 OPEN 状态
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");

        // 进入“计算中奖者”状态
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 构造一个 VRF 请求（存在 memory）
        ///创建 struct（结构体），不是在赋值变量,所以用：
        VRFV2PlusClient.RandomWordsRequest memory req =
            VRFV2PlusClient.RandomWordsRequest({

                keyHash: keyHash, // 指定随机数服务

                subId: subscriptionId, // 付费账户

                requestConfirmations: requestConfirmations, // 等待确认数

                callbackGasLimit: callbackGasLimit, // 回调 gas

                numWords: numWords, // 随机数个数

                // 是否用原生ETH支付
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: true
                    })
                )
            });

        // 向 Chainlink 发送请求
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    // ===== Chainlink 自动回调（你不能手动调用！）=====
    ///自动调用是为了防止作弊
    function fulfillRandomWords(
        uint256,                  // requestId（这里没用）
        uint256[] calldata randomWords // 返回的随机数
    )
        internal
        override
    {
        // 必须在 CALCULATING 状态
        require(
            lotteryState == LOTTERY_STATE.CALCULATING,
            "Not ready to pick winner"
        );

        // 用随机数选一个赢家
        uint256 winnerIndex = randomWords[0] % players.length;

        address payable winner = players[winnerIndex];

        // 记录赢家
        recentWinner = winner;

        // 清空玩家列表（重置）！！！这里原代码有个错误，初始化需要逐个操作
        players = new address payable[](0);

        // 关闭彩票
        lotteryState = LOTTERY_STATE.CLOSED;

        // 把所有 ETH 发给赢家
        (bool sent, ) = winner.call{value: address(this).balance}("");

        require(sent, "Failed to send ETH to winner");
    }

    // ===== 查看玩家列表 =====
    function getPlayers()
        external
        view
        returns (address payable[] memory)
    {
        return players;
    }
}