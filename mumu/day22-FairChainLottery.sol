// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @notice 实现一个防篡改、自动化、链上彩票系统
    @dev 每轮结束时，合约会想chainlink请求一个随机数，从池中选出一位幸运赢家，并向该赢家发送所有ETH
    @dev VRFConsumerBaseV2Plus —— fulfillRandomWords
    @dev VRFV2PlusClient 辅助构造和格式化我们发送给chainlink的随机性请求
 */

contract FairChainLottery is VRFConsumerBaseV2Plus {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    // 抽奖活动状态
    LOTTERY_STATE public lotteryState;

    // 参与玩家
    address payable[] public players;
    // 上一轮赢家
    address public recentWinner;
    // 入场费
    uint256 public entryFee;

    // Chainlink VRF 配置
    // chainlink账户id
    uint256 public subscriptionId;
    // 运行什么chainlink语言机任务
    bytes32 public keyHash;
    // gas预算，最多可以使用多少个gas
    uint32 public callbackGasLimit = 100000;
    // Chainlink 在生成随机数之前等待多少个区块确认
    uint16 public requestConfirmations = 3;
    // 一次请求多少个随机数
    uint32 public numWords = 1;
    // 每次请求，chainlink会返回一个请求ID
    uint256 public latestRequestId;

    constructor(
        address vrfCoordinator, // VRF协调器的地址
        uint256 _subscriptionId, // chainlink订阅id（用于支付VRF请求
        bytes32 _keyHash, // 指定chainlink使用哪个随机任务
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;

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

        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    // chainlink的回调函数，通过调用这个函数将我们请求的结果发送会给我们的合约
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 根据index选择赢家
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        // 为下一轮做准备
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;

        // 给赢家发放奖金
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}

