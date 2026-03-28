// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 将真正的随机性引入我们的合约
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {
    enum LOTTERY_STATE {
        // 彩票正在进行，玩家可以参与
        OPEN,
        // 彩票不活跃。没有参与，没有选择。只是休息。
        CLOSED,
        // 彩票目前正在向 Chainlink 请求随机数，在我们获得结果之前没有人可以参与或重启游戏。
        CALCULATING}
    LOTTERY_STATE public lotteryState;

    // 玩家跟踪
    address payable[] public players;
    address public recentWinner; // 记住上一轮谁赢了
    uint256 public entryFee;

    // Chainlink VRF 配置
    // 这就像你的 Chainlink 账户 ID —— 它与你的 Chainlink 订阅绑定，你用 LINK 代币为其充值以支付预言机服务。每次发出随机性请求时，LINK 都会从你的订阅中扣除。
    uint256 public subscriptionId;
    // 这标识了你想要运行哪个 Chainlink 预言机任务。
    bytes32 public keyHash;
    // 为 Chainlink 在用结果回调你的合约时设置了一个 gas 预算
    uint32 public callbackGasLimit = 100000;
    // Chainlink 在生成随机数之前等待多少个区块确认。
    uint16 public requestConfirmations = 3;
    // 在一次请求中想要多少个随机数。
    uint32 public numWords = 1;
    // 一个请求 ID
    uint256 public latestRequestId;

    // vrfCoordinator - 要部署到的区块链上 Chainlink VRF 协调器的地址。它充当接收随机性请求并返回结果的中间人。
    constructor(address vrfCoordinator, uint256 _subscriptionId, bytes32 _keyHash, uint256 _entryFee) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 给我们提供了一种简单的方式来构造和格式化我们发送给 Chainlink 的随机性请求。它让我们可以配置以下内容：
        // - 我们想要多少个随机数
        // - 回调使用多少 gas
        // - 使用哪个 Chainlink 任务（通过 `keyHash`）
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

    // 继承自VRFConsumerBaseV2Plus 当随机数准备好时，Chainlink 会自动调用它。可以把它看作是随机数的"回调"插槽。
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;

        (bool sent,) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

}

