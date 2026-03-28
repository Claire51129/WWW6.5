// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
//Chainlink 提供的一个基础合约, fulfillRandomWords函数:当随机数准备好时，Chainlink会自动调用它。可以把它看作是随机数的"回调"插槽。
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract FairChainLottery is VRFConsumerBaseV2Plus {//继承Chainlink VRF合约
    //控制彩票流程
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    //enum = 自定义 “状态 / 选项” 的变量,它只能存你预先定义好的几个固定值。目前定义了开票、关闭和正在请求随机数三种状态
    LOTTERY_STATE public lotteryState;
    address payable[] public players;//所有买彩票的人
    address public recentWinner;//上一轮赢家地址
    uint256 public entryFee;//参加费用：某人必须支付多少 ETH 才能加入

    // Chainlink VRF 配置
    uint256 public subscriptionId;//摇随机数需要用到的地址
    bytes32 public keyHash;//标识了你想要运行哪个 Chainlink 预言机任务,keyHash 是一个唯一标识符
    uint32 public callbackGasLimit = 100000;//给 Chainlink 回调时预留的 Gas
    uint16 public requestConfirmations = 3;//这设置了 Chainlink 在生成随机数之前等待多少个区块确认，提高安全性，防止黑客篡改
    uint32 public numWords = 1;//一次请求中只需要一个随机数
    uint256 public latestRequestId;//最新一次请求id

    constructor(
        address vrfCoordinator,// VRF 协调器地址
        uint256 _subscriptionId,// 你的 Chainlink 订阅ID
        bytes32 _keyHash,//定义了 Chainlink 应该使用哪个随机性任务
        uint256 _entryFee//定义了门票钱
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    //售票
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");//保证为开票状态
        require(msg.value >= entryFee, "Not enough ETH");//保证有钱买门票
        players.push(payable(msg.sender));//用payable来包装msg.sender是为了玩家赢钱后可以在直接给账户转钱
    }

   //只有管理员可以开始游戏
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    //管理员结束游戏
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;//修改状态为摇数中

        //构造随机数请求
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

    //由Chainlink自动调用
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;

        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}