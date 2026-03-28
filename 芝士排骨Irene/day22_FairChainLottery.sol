// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 Chainlink VRF V2.5 版本的合约
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 去中心化彩票合约
contract FairChainLottery is VRFConsumerBaseV2Plus {

    // 彩票状态枚举
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }

    LOTTERY_STATE public lotteryState;          // 当前状态
    address payable[] public players;           // 参与者列表
    address public recentWinner;                // 最近一次中奖者
    uint256 public entryFee;                    // 门票价格

    // Chainlink VRF 配置参数
    uint256 public subscriptionId;              // Chainlink 订阅 ID（预充代币用于支付随机数费用）
    bytes32 public keyHash;                     // 密钥哈希（选择使用哪个 Chainlink 节点）
    uint32 public callbackGasLimit = 100000;    // 回调函数的 gas 上限
    uint16 public requestConfirmations = 3;     // 等几个区块确认后返回结果
    uint32 public numWords = 1;                 // 请求几个随机数（抽一个中奖者只需要 1 个）
    uint256 public latestRequestId;             // 最近一次请求的 ID

    // 构造函数
    constructor(
        address vrfCoordinator,        // Chainlink VRF 协调器地址（每条链不同）
        uint256 _subscriptionId,       // 订阅 ID
        bytes32 _keyHash,              // 节点密钥哈希
        uint256 _entryFee              // 门票价格
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;  // 初始关闭，需要管理员手动开启
    }

    // 参与彩票 - 玩家付门票费入场
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");  // 必须在开放状态
        require(msg.value >= entryFee, "Not enough ETH");                 // 付的钱必须够
        players.push(payable(msg.sender));  // 加入参与者列表
    }

    // 开始彩票 - 仅管理员可操作
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;  // 开放售票
    }

    // 结束彩票并请求随机数 - 仅管理员可操作
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;  // 进入计算状态，停止售票

        // V2.5 新版写法：用结构体打包所有请求参数
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,                    // 选择哪个 Chainlink 节点
            subId: subscriptionId,               // 用哪个订阅账户付费
            requestConfirmations: requestConfirmations,  // 等几个区块确认
            callbackGasLimit: callbackGasLimit,          // 回调函数 gas 上限
            numWords: numWords,                          // 要几个随机数
  
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });

        // s_vrfCoordinator 是从母合约继承来的变量，指向 Chainlink VRF 协调器
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    // VRF 回调函数 - Chainlink 生成随机数后自动调用
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 用随机数选中奖者
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        // 重置彩票
        players = new address payable[](0);     // 清空参与者列表
        lotteryState = LOTTERY_STATE.CLOSED;     // 状态改回关闭

        // 把奖池所有 ETH 转给中奖者
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    // 获取所有参与者地址
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}