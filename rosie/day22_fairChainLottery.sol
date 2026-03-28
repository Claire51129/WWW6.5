// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//要从Chainlink接受随机数，必须用以下两个道具
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus{
    //定义枚举
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    //彩票站状态
    LOTTERY_STATE public lotteryState;
    //参加人列表，都是可以支付钱的
    address payable[] public players;
    //最新赢家
    address public recentWinner;
    //入场费
    uint256 public entryFee;

    // Chainlink VRF 配置，要向Chainlink请求随机数，必须有以下的变量
    //Chainlink上的注册ID，让chainlink直到从谁手里扣除link（link是什么?是一种代币，可以在sopilia网站上领取）
    uint256 public subscriptionId;
    //告诉chainlink这个合约想用它的什么服务
    bytes32 public keyHash;
    //Chainlink 必须调用这个合约的 `fulfillRandomWords()` 函数来传递随机数,这个函数调用需要 gas。这个数字告诉 Chainlink："在履行请求时，你可以使用最多 X 个 gas。"
    //100000不多不少
    uint32 public callbackGasLimit = 100000;
    //设置区块确认，因为随机数的生成需要“种子”，种子由3部分组成；区块哈希，chainlink节点秘钥，用户提供的种子。
    //合约发起随机数请求时，chainlink节点不会立刻响应，而是等待链上产生3个新块，得到这个新块儿的哈希作为种子的一部分
    uint16 public requestConfirmations = 3;
    //告诉chainlink这个合约要多少个随机数
    uint32 public numWords = 1;
    //随机数生成的订单编号
    uint256 public latestRequestId;

    constructor(
    address vrfCoordinator,//协调器地址，从哪里得到？从这里https://vrf.chain.link/sepolia，要连接钱包，连接号以后要Create Subscription
    //我的订阅账号：72814694689365274505237821495091336822600195906923036509272275213888718120695
    uint256 _subscriptionId,
    //从https://vrf.chain.link/sepolia的订阅链接获取
    bytes32 _keyHash,
    //玩乐透的最低费用
    uint256 _entryFee) VRFConsumerBaseV2Plus(vrfCoordinator) {
    subscriptionId = _subscriptionId;
    keyHash = _keyHash;
    entryFee = _entryFee;
    //默认彩票站关闭，因为我们要控制
    lotteryState = LOTTERY_STATE.CLOSED;
    }
    //参与乐透
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        //需要把玩家标记为可支付，后面她们赢了，我们就给她们打钱
        players.push(payable(msg.sender));
    }
    //只能是彩票站站长决定开启或者关闭乐透
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }
    //结束此次乐透
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;
        //VRFV2PlusClient是一个结构体，RandomWordsRequest是一个变量类型，结构体中的结构体
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            //启用原生代币支付，不写这个默认使用link，link不够还要充值
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });

        //发送请求
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    //不调用 fulfillRandomWords() —— Chainlink 在返回随机数时自动调用此函数，这个函数是母合约中的继承的，重写为内部合约
    //整个过程：我的合约（继承自母合约）→在endLottery()函数触发时提供了我这个合约的地址和标准回调标识→chainlink按照标准操作→调用我合作继承自母合约的公共函数→这个公共函数自动调用了我这个内部函数
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");
        //用趋于的方法决定获奖的玩家ID
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;
        //为下一轮进行重置，清空这一轮的玩家，彩票站关闭
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        //给赢家发钱
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }
    //获取这一轮所有玩家
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

}

