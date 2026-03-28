// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入Chainlink VRF核心合约（用来生成真随机数）
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 去中心化彩票主合约
contract FairChainLottery is VRFConsumerBaseV2Plus {
    // 抽奖的3个状态：开放买票 / 计算中奖 / 抽奖结束
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState; // 当前抽奖的状态

    // 存储所有参与抽奖的玩家地址
    address payable[] public players;
    // 上一轮的中奖者地址
    address public recentWinner;
    // 门票价格（单位：wei，1 ETH = 10^18 wei）
    uint256 public entryFee;

    // --------------------------
    // Chainlink VRF 固定配置参数（不用手动改）
    // --------------------------
    uint256 public subscriptionId;    // VRF订阅ID（Chainlink平台申请）
    bytes32 public keyHash;           // VRF密钥哈希（Chainlink提供）
    uint32 public callbackGasLimit = 100000; // 回调函数的Gas上限
    uint16 public requestConfirmations = 3;  // 区块确认数（确保安全）
    uint32 public numWords = 1;       // 要生成的随机数个数（这里只需要1个）
    uint256 public latestRequestId;   // 最新的随机数请求ID

   

    // --------------------------
    // 构造函数：部署合约时初始化
    // --------------------------
    constructor(
        address vrfCoordinator,    // VRF协调器地址（Chainlink官方提供）
        uint256 _subscriptionId,   // VRF订阅ID
        bytes32 _keyHash,          // VRF密钥哈希
        uint256 _entryFee          // 门票价格
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED; // 初始状态：抽奖关闭
    }

    // --------------------------
    // 功能1：玩家买票入场（核心功能）
    // --------------------------
    function enterLottery() external payable {
        // 必须是「开放买票」状态才能入场
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery is not open");
        // 必须付 exactly 门票钱，不能多也不能少
        require(msg.value == entryFee, "Must pay exact entry fee");

        // 把玩家地址加入抽奖列表
        players.push(payable(msg.sender));
    }

    // --------------------------
    // 功能2：主办方结束抽奖，请求随机数
    // --------------------------
    function endLottery() external onlyOwner { // ✅ 用父合约的onlyOwner，无需自己实现
        // 必须是「开放买票」状态才能结束
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 把状态改成「计算中」，停止售票
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 构造随机数请求（给Chainlink VRF）
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

        // 发送随机数请求，记录请求ID
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    // --------------------------
    // 功能3：VRF返回随机数，自动开奖发奖（公平核心！）
    // --------------------------
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        // 必须是「计算中」状态才能开奖
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 用随机数取余，得到中奖者的索引（绝对公平，没人能操控）
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        // 清空玩家列表，准备下一轮抽奖
        players = new address payable[](0);
        // 把状态改成「抽奖结束」
        lotteryState = LOTTERY_STATE.CLOSED;

        // 把合约里所有的奖金（玩家付的门票钱）全转给中奖者
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    // --------------------------
    // 辅助功能：查看所有参与抽奖的玩家
    // --------------------------
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

    // --------------------------
    // 辅助功能：主办方开启新一轮抽奖
    // --------------------------
    function startLottery() external onlyOwner { // ✅ 用父合约的onlyOwner，无需自己实现
        // 必须是「抽奖结束」状态才能开启新轮次
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery not closed");
        lotteryState = LOTTERY_STATE.OPEN;
    }
}