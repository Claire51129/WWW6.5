// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//导入VRF的库
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
//Chainlink提供的一个基础合约，得到一个名为 fulfillRandomWords 的特殊函数
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
//辅助库，可以配置以下内容：我们想要多少个随机数，回调使用多少 gas，使用哪个 Chainlink 任务
contract FairChainLottery is VRFConsumerBaseV2Plus 
{
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }//枚举，三种状态
    LOTTERY_STATE public lotteryState;

    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    // Chainlink VRF 配置
    uint256 public subscriptionId;//Chainlink 账户 ID
    bytes32 public keyHash;//使用哪个功能
    uint32 public callbackGasLimit = 100000;//gas预算
    uint16 public requestConfirmations = 3;// Chainlink 在生成随机数之前等待多少个区块确认，轻微延迟，增加安全性，避免被操纵
    uint32 public numWords = 1;//一次请求中想要多少个随机数
    uint256 public latestRequestId;//跟踪请求ID

    constructor(
        address vrfCoordinator,//Chainlink VRF 协调器的地址
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) 
    {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;//默认CLOSED
    }

    function enter() public payable 
    {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));//将玩家添加到列表中，标记为 payable，以便向其转账（如果赢了）
    }

    function startLottery() external onlyOwner 
    {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;//游戏开始
    }

    function endLottery() external onlyOwner 
    {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;//状态变为CALCULATING

        //发起随机性请求
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest(
        {
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
        //将请求发送到 Chainlink VRF
    }

    //Chainlink 在返回随机数时自动调用此函数
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override 
    {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;//取余
        address payable winner = players[winnerIndex];//列表中的第Index+1个玩家获胜
        recentWinner = winner;//储存赢家

        players = new address payable[](0);//清空玩家列表
        lotteryState = LOTTERY_STATE.CLOSED;//关闭

        (bool sent, ) = winner.call{value: address(this).balance}("");//发送ETH
        require(sent, "Failed to send ETH to winner");
    }

    //当前玩家列表
    function getPlayers() external view returns (address payable[] memory) 
    {
        return players;
    }
}
