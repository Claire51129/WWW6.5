// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//链上随机性的直接链接
//随机数的"回调"插槽,继承特殊函数当随机数准备好时自动调用
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
//构造和格式化我们发送给 Chainlink 的随机性请求
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {
    //enum(枚举)创建变量可以取的命名状态列表
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;//变量管理游戏流程，并在正确的时间执行正确的规则

    address payable[] public players; //本轮加入的玩家
    address public recentWinner;      //上轮的赢家
    uint256 public entryFee;          //加入必须支付的ETH

    // Chainlink VRF 配置
    uint256 public subscriptionId;    //订阅账户ID
    bytes32 public keyHash;           //链接特定的预言机任务
    uint32 public callbackGasLimit = 100000;  //gas预算设置
    uint16 public requestConfirmations = 3;   //在生成随机数之前等待3个区块确认
    uint32 public numWords = 1;               //一次请求1个随机数
    uint256 public latestRequestId;           //请求ID

    constructor(
        address vrfCoordinator,//部署到的区块链上 Chainlink VRF 协调器的地址
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;//默认将 lotteryState 设置为 CLOSED
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));//将玩家添加到列表中
    }

    //开始抽奖
    function startLottery() external onlyOwner {
        //确保我们不会在另一轮已经在进行时开始一轮
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;//翻转开关，游戏开始
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");//只在彩票当前处于活动状态时结束它
        lotteryState = LOTTERY_STATE.CALCULATING;//翻转为选择赢家的过程

        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            //将「原生代币支付」的配置参数，通过 Chainlink 官方库转换为合约可识别的字节格式
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });

        //将请求发送到 Chainlink VRF
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    //返回随机数时自动调用
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        //检查合约确实处于选择赢家的过程中
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;//索引值（从0开始）=随机数%玩家数
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        players = new address payable[](0);//清空玩家列表
        lotteryState = LOTTERY_STATE.CLOSED;//关闭彩票

        (bool sent, ) = winner.call{value: address(this).balance}("");//将合约中存储的所有 ETH 发送给赢家
        require(sent, "Failed to send ETH to winner");//检查转账，失败回滚
    }

    //返回当前玩家列表
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}

