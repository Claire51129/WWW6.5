// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 Chainlink VRF (可验证随机函数) 的核心合约
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title 公平链上抽奖合约
 * @notice 这是一个展示如何利用 Chainlink VRF 获取随机数并自动派奖的示例
 */
contract FairChainLottery is VRFConsumerBaseV2Plus {
    
    // 定义抽奖的三个阶段：开放、关闭、计算中
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;

    // 存储玩家地址的动态数组，payable 表示可以给这些地址转钱
    address payable[] public players;
    address public recentWinner; // 最近一次的中奖者地址
    uint256 public entryFee;     // 入场门票费 (单位: wei)

    // Chainlink VRF 相关配置
    uint256 public subscriptionId;    // 订阅 ID，用于支付随机数服务费
    bytes32 public keyHash;           // 这里的“钥匙”决定了你愿意支付的最高 Gas 价格
    uint32 public callbackGasLimit = 100000; // 预留给回调函数执行的 Gas 上限
    uint16 public requestConfirmations = 3;  // 等待多少个区块确认以保证随机数更安全
    uint32 public numWords = 1;       // 我们只需要 1 个随机数
    uint256 public latestRequestId;   // 记录最近一次请求的 ID

    /**
     * @dev 构造函数：部署合约时初始化参数
     */
    constructor(
        address vrfCoordinator, // VRF 协调器合约地址（由 Chainlink 提供）
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED; // 初始状态设为关闭
    }

    /**
     * @notice 玩家参与抽奖
     */
    function enter() public payable {
        // 1. 检查：必须是开放状态
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 2. 检查：付的钱必须够门票费
        require(msg.value >= entryFee, "Not enough ETH");
        // 3. 记录玩家地址
        players.push(payable(msg.sender));
    }

    /**
     * @notice 管理员开启抽奖
     */
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    /**
     * @notice 管理员结束抽奖并请求随机数
     * @dev 这是异步流程的第一步
     */
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        
        // 立刻锁定状态，防止异步期间有人继续入场
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 构建 Chainlink 随机数请求参数
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true}) // 使用原生代币(如ETH)支付
            )
        });

        // 向 Chainlink 节点发送请求，返回一个请求 ID
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    /**
     * @notice Chainlink 节点计算完随机数后，会自动回调这个函数
     * @dev 这是异步流程的第二步：结算中奖者
     * @param randomWords Chainlink 返回的随机数数组
     */
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        // 检查状态，确保此时确实在等待结果
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 通过求余数，从大随机数中选出数组下标
        // 例如：101 % 3 = 2，中奖者就是 players[2]
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        // 重置数组（清空抽奖箱）
        players = new address payable[](0);
        // 重置状态为关闭
        lotteryState = LOTTERY_STATE.CLOSED;

        // 将合约内所有的 ETH 发送给赢家
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    /**
     * @notice 查看当前所有参与者
     */
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}