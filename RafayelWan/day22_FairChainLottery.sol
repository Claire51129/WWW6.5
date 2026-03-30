// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 Chainlink VRF
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {

    /* ========== 🎭 状态定义 ========== */

    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;

    /* ========== 👥 玩家数据 ========== */

    address payable[] public players; // 玩家列表
    address public recentWinner;      // 最近赢家
    uint256 public entryFee;          // 入场费

    /* ========== 🔗 VRF 配置 ========== */

    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 200000; // 提高一点更安全
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;

    /* ========== 📢 事件 ========== */

    event LotteryStarted();
    event LotteryEntered(address indexed player);
    event LotteryEnded(uint256 requestId);
    event WinnerPicked(address indexed winner);

    /* ========== 🛠️ 构造函数 ========== */

    constructor(
        address vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;

        lotteryState = LOTTERY_STATE.CLOSED; // 初始关闭
    }

    /* ========== 🎟️ 参与彩票 ========== */

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");

        players.push(payable(msg.sender));

        emit LotteryEntered(msg.sender);
    }

    /* ========== 🟢 开始彩票 ========== */

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");

        lotteryState = LOTTERY_STATE.OPEN;

        emit LotteryStarted();
    }

    /* ========== 🔴 结束彩票 ========== */

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(players.length > 0, "No players"); // 防止除0错误

        lotteryState = LOTTERY_STATE.CALCULATING;

        // 构造 VRF 请求
        VRFV2PlusClient.RandomWordsRequest memory req =
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                )
            });

        // 发送请求
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);

        emit LotteryEnded(latestRequestId);
    }

    /* ========== 🏆 VRF 回调 ========== */

    function fulfillRandomWords(
        uint256,
        uint256[] calldata randomWords
    ) internal override {

        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready");

        // 选出赢家
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];

        recentWinner = winner;

        // ✅ 修复点：正确清空数组
        players = new address payable[](0);

        // 重置状态
        lotteryState = LOTTERY_STATE.CLOSED;

        // 转账奖金
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Transfer failed");

        emit WinnerPicked(winner);
    }

    /* ========== 🔍 查询函数 ========== */

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}