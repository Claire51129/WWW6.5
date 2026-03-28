
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
抛个硬币。向所有人展示结果。然后把它锁定到区块链上
-----随机验证 防止造假
- 🎲 一个**随机数**，
- 🧾 一个**密码学证明**，证明它是公平生成的，
- 📦 +传递给你的智能合约
**/
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";



// 去中心化彩票系统
contract FairChainLottery is VRFConsumerBaseV2Plus {

/**
enum 是 enumeration（枚举）
- `OPEN` —— 彩票正在进行，**玩家可以参与**。
- `CLOSED` —— 彩票**不活跃**。没有参与，没有选择。只是休息。
- `CALCULATING` —— 彩票目前**正在向 Chainlink 请求随机数**，在我们获得结果之前**没有人可以参与或重启游戏**
**/
// LOTTERY_STATE-->控制流程
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;
// - `players` 存储本轮加入的每个人。
// - `recentWinner` 记住上一轮谁赢了。
// - `entryFee` 设置某人必须支付多少 ETH 才能加入
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    // Chainlink VRF 配置
    uint256 public subscriptionId;//Chainlink 账户 ID 
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;//设置了 Chainlink 在生成随机数之前等待多少个区块确认。
    uint32 public numWords = 1;//在一次请求中想要多少个随机数
    uint256 public latestRequestId;//随机性订单的票号

    constructor(
        address vrfCoordinator,//接受随机性请求结果
        uint256 _subscriptionId,//Chainlink 订阅 ID
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;//钱
        lotteryState = LOTTERY_STATE.CLOSED;//状态
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
        /**我们用 payable(...) 包装 msg.sender，
        因为我们计划稍后可能会向这个地址发送 ETH（如果他们赢了）。
        Solidity 需要我们将其标记为 payable，以便向其转移资金。**/
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;//游戏开始
// 发送Chainlink 的随机性请求
/**- 使用哪个随机性任务（`keyHash`）
- 谁在付款（`subscriptionId`）
- 等待多少确认
- 响应时使用多少 gas
- 我们想要多少个随机数（在这种情况下，只有 `1`）**/
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
//  由 Chainlink 自动调用
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;
// 为下一轮重置
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
// 发送奖金--将合约中存储的所有 ETH 发送给幸运的赢家
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}

