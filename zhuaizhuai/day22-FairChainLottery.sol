// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入Chainlink VRF（随机数）相关库
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// 公平链上抽奖合约
// 使用Chainlink VRF生成真正的随机数，防止作弊！
contract FairChainLottery is VRFConsumerBaseV2Plus {

    // 抽奖状态：只有三种情况
    enum LOTTERY_STATE {
        OPEN,        // 开放购票中
        CLOSED,      // 已关闭
        CALCULATING  // 正在抽奖中
    }

    LOTTERY_STATE public lotteryState;          // 当前抽奖状态
    address payable[] public players;           // 所有参与者地址列表
    address public recentWinner;                // 最近一次中奖者
    uint256 public entryFee;                    // 参与费用

    // Chainlink VRF 配置（用来获取随机数）
    uint256 public subscriptionId;              // Chainlink订阅ID
    bytes32 public keyHash;                     // 指定使用哪个VRF节点
    uint32 public callbackGasLimit = 100000;    // 回调函数的gas上限
    uint16 public requestConfirmations = 3;     // 需要等待几个区块确认
    uint32 public numWords = 1;                 // 需要几个随机数（只需要1个）
    uint256 public latestRequestId;             // 最新的随机数请求ID

    // 部署时设置VRF和抽奖参数
    constructor(
        address vrfCoordinator,    // Chainlink VRF协调器地址
        uint256 _subscriptionId,   // 订阅ID
        bytes32 _keyHash,          // VRF节点标识
        uint256 _entryFee          // 参与费用
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;  // 默认关闭
    }

    // 参与抽奖
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");  // 必须是开放状态
        require(msg.value >= entryFee, "Not enough ETH");                  // 必须付够费用
        players.push(payable(msg.sender));  // 加入参与者列表
    }

    // 开启抽奖（只有owner能调用）
    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;  // 改成开放状态
    }

    // 结束抽奖，向Chainlink请求随机数（只有owner能调用）
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;  // 改成计算中状态

        // 构造随机数请求
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,                    // 使用哪个VRF节点
            subId: subscriptionId,               // 订阅ID
            requestConfirmations: requestConfirmations,  // 等待3个区块确认
            callbackGasLimit: callbackGasLimit,  // 回调gas限制
            numWords: numWords,                  // 需要1个随机数
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                // 用ETH支付VRF费用
            )
        });

        // 向Chainlink发送随机数请求
        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    // Chainlink回调函数：收到随机数后自动执行
    // 这个函数不能手动调用，只有Chainlink能调用！
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 用随机数决定中奖者
        uint256 winnerIndex = randomWords[0] % players.length;
        // 比如：随机数是12345，参与者有10人
        // 12345 % 10 = 5 → 第5个参与者中奖！

        address payable winner = players[winnerIndex];  // 找到中奖者
        recentWinner = winner;                           // 记录中奖者

        // 重置抽奖
        players = new address payable[](0);  // 清空参与者列表
        lotteryState = LOTTERY_STATE.CLOSED; // 关闭抽奖

        // 把所有奖金转给中奖者！
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH to winner");
    }

    // 查询所有参与者
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}
