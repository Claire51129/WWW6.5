// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 下面两行是借来“公平摇奖机”工具，绝对不能作弊
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 合约名字：公平链彩票，继承摇奖机功能
contract FairChainLottery is VRFConsumerBaseV2Plus {

    // 彩票三种状态：开门、关门、算奖
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    // 记录现在彩票是开、关、还是算奖
    LOTTERY_STATE public lotteryState;

    //玩家数据 
    // 记录所有买票的人
    address payable[] public players;
    // 记录最近中奖的人
    address public recentWinner;
    // 买一张票要多少钱
    uint256 public entryFee;

    // 摇奖机配置 
    // 摇奖机账号ID
    uint256 public subscriptionId;
    // 摇奖机密钥
    bytes32 public keyHash;
    // 摇奖手续费额度
    uint32 public callbackGasLimit = 200000;
    // 摇奖确认次数
    uint16 public requestConfirmations = 3;
    // 要几个随机数
    uint32 public numWords = 1;
    // 最近一次摇奖请求编号
    uint256 public latestRequestId;

    //广播消息
    // 彩票开始了
    event LotteryStarted();
    // 有人买票了
    event LotteryEntered(address indexed player);
    // 彩票结束了
    event LotteryEnded(uint256 requestId);
    // 选出中奖人
    event WinnerPicked(address indexed winner);

    //刚创建合约时执行
    constructor(
        address vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        // 保存摇奖机ID
        subscriptionId = _subscriptionId;
        // 保存摇奖密钥
        keyHash = _keyHash;
        // 保存票价
        entryFee = _entryFee;
        // 一开始彩票是关闭的
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    //买票功能 
    function enter() public payable {
        // 必须彩票开门才能买
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 必须付够钱
        require(msg.value >= entryFee, "Not enough ETH");
        // 把买票人加入名单
        players.push(payable(msg.sender));
        // 广播：XXX买票了
        emit LotteryEntered(msg.sender);
    }

    // 管理员：开始彩票 
    function startLottery() external onlyOwner {
        // 必须是关闭状态才能开始
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        // 改成开门状态
        lotteryState = LOTTERY_STATE.OPEN;
        // 广播：彩票开始
        emit LotteryStarted();
    }

    // 管理员：结束彩票，准备开奖 
    function endLottery() external onlyOwner {
        // 必须开门才能结束
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        // 必须有人买票
        require(players.length > 0, "No players");
        // 改成“算奖中”
        lotteryState = LOTTERY_STATE.CALCULATING;

        // 构造摇奖请求
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

        // 向官方摇奖机要随机数
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
        // 广播：彩票结束，开始摇奖
        emit LotteryEnded(latestRequestId);
    }

    //自动开奖、自动发钱
    function fulfillRandomWords(
        uint256,
        uint256[] calldata randomWords
    ) internal override {
        // 必须是算奖中才能开奖
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready");

        // 用随机数选一个中奖人
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];

        // 记录中奖人
        recentWinner = winner;
        // 清空玩家列表，准备下一轮
        players = new address payable[](0);
        // 彩票状态变回关闭
        lotteryState = LOTTERY_STATE.CLOSED;

        // 把所有钱转给中奖人
        (bool sent, ) = winner.call{value: address(this).balance}("");
        // 检查转账是否成功
        require(sent, "Transfer failed");

        // 广播：中奖人诞生！
        emit WinnerPicked(winner);
    }

    //查看所有买票的人
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}