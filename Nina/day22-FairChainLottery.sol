// Chainlink VRF —— 一个在链上工作的可信随机性来源

/* Chainlink VRF 的工作机制——获取随机数是一个异步的过程，分为两步：
请求阶段：你的合约向 Chainlink 发起请求。
回调阶段：Chainlink 节点生成随机数后，会调用你合约中的 fulfillRandomWords 函数。
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING } // enum 是 enumeration（枚举）的缩写，在 Solidity 中，它是一种创建变量可以取的命名状态列表的方法。
    LOTTERY_STATE public lotteryState;

    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    // Chainlink VRF 配置
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000; // 回调时，Chainlink发起交易并支付gas费，最终扣除你的订阅费用，你承担后果。
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;

    constructor(
        address vrfCoordinator, // 这是你要部署到的区块链上 Chainlink VRF 协调器的地址。它充当接收随机性请求并返回结果的中间人。
        uint256 _subscriptionId, // 这是你的 Chainlink 订阅 ID（用于支付 VRF 请求）。
        bytes32 _keyHash, // 这定义了 Chainlink 应该使用哪个随机性任务。
        uint256 _entryFee // 这设置了玩家必须支付多少 ETH 才能参与每轮彩票。
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }
    // https://chainlist.org/
    // https://docs.chain.link/vrf/v2-5/supported-networks#base-sepolia-testnet
    // https://vrf.chain.link/base-sepolia

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender)); // 我们**将玩家添加到列表中**。——我们用 `payable(...)` 包装 `msg.sender`，因为我们计划稍后可能会向这个地址发送 ETH（如果他们赢了）。Solidity 需要我们将其标记为 `payable`，以便向其转移资金。
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({ // 我们正在制作一个要发送给 Chainlink 的**随机性请求**。这个对象告诉 Chainlink 它需要知道的一切：
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            ) 
            /** 在 Chainlink VRF V2 Plus 中，extraArgs 是一个非常灵活的参数，它允许开发者为请求添加额外的配置。
                简单来说，这段代码的作用是告诉 Chainlink 节点你打算如何支付这笔随机数请求的费用。

                这段代码由两个部分组成：数据内容和格式转换。
                1. 数据内容 (ExtraArgsV1):
                    这是一个结构体（Struct），目前最关键的字段是 nativePayment。
                        nativePayment: true: 表示你希望使用区块链原生代币（如 Ethereum 上的 ETH，Polygon 上的 POL）来支付费用。
                        nativePayment: false:（默认值）表示你将使用 LINK 代币来支付费用。
                2. 格式转换 (_argsToBytes):
                由于智能合约的接口为了通用性，通常将额外的配置信息接收为 bytes 类型。这个函数的作用是将结构体中的配置信息“打包”成一种 EVM 能够理解并传输的二进制格式。
             */
        });

        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
        /** 将请求发送到 Chainlink VRF

        1. s_vrfCoordinator：调度中心 
        s_vrfCoordinator 是 Chainlink 在链上部署的一个合约地址。它就像是一个中转站或调度员。你的合约不直接生成随机数（因为链上生成的随机数容易被预测），而是通过这个调度员向链外的预言机节点集群发信号。

        2. requestRandomWords(req)：提交申请 
        这里的 req 就是你之前定义的那个结构体，里面包含了：
            Gas 限制（callbackGasLimit）
            确认数（requestConfirmations）
            支付方式（nativePayment）
        当你调用这个函数时，调度员合约会进行一系列检查（比如你的订阅账户钱够不够），然后发出一个链上事件（Event）。

        3. latestRequestId：你的“快递单号” 
        这是这行代码最巧妙的地方。requestRandomWords 函数会立即返回一个 uint256 类型的唯一标识符。
            异步特性：随机数并不会立即返回。就像你下单买快递，系统会先给你一个单号（RequestId），而包裹（随机数）要等会儿才送到。
            追踪作用：你可以用这个 ID 来记录当前是哪次抽奖在等待结果。如果你的合约支持同时进行多次抽奖，这个 ID 就是区分它们的唯一凭证。
        
        此时，我们的工作完成了 —— 合约等待 Chainlink 用随机数响应。
        这是很酷的部分：**我们不手动调用下一个函数。**
         */
    }

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override { // Chainlink 在返回随机数时自动调用此函数【这就是预言机与智能合约交互方式的美妙之处 —— 事件驱动编程的最佳体现】
        // 安全检查
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        // 选择赢家
        uint256 winnerIndex = randomWords[0] % players.length; // 模运算 - 求余数。余数一定小于除数。【假设有5个玩家，他们的索引（Index）是：[0, 1, 2, 3, 4]。这里的玩家总数（players.length）是5。当我们执行 randomWords[0] % 5 时：无论随机数有多大（哪怕是几千亿），计算出的结果一定落在 0, 1, 2, 3, 4 这五个数字之中。这正好对应了数组中每一个存在的索引，不多也不少。】
        address payable winner = players[winnerIndex];
        
        // 宣布赢家
        recentWinner = winner;

        // 为下一轮重置 —— 清空玩家列表并关闭彩票
        players = new address payable[](0); // 重新初始化 players 数组：（1）new address payable[]: 声明我们要创建一个新的、类型为“可支付地址”的动态数组。（2）(0): 括号里的数字表示新数组的初始长度。
        lotteryState = LOTTERY_STATE.CLOSED;

        // 发送奖金
        (bool sent, ) = winner.call{value: address(this).balance}(""); // 将合约中存储的所有 ETH 发送给幸运的赢家
        require(sent, "Failed to send ETH to winner");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}

