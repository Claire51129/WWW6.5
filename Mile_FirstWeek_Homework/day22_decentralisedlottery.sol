// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 修正后的导入路径：使用标准的 v2 接口和基类
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title 去中心化彩票合约
 * @dev 修复了导入路径问题，支持标准的 Chainlink VRF V2
 */
contract DecentralisedLottery is VRFConsumerBaseV2, Ownable {
    // --- 类型定义 ---
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }

    // --- 状态变量 ---
    LOTTERY_STATE public lotteryState;
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    // --- Chainlink VRF 配置 ---
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;

    // --- 事件 ---
    event LotteryEntered(address indexed player, uint256 entryFee);
    event LotteryStarted();
    event LotteryEnded();
    event RandomnessRequested(uint256 indexed requestId);
    event WinnerPicked(address indexed winner, uint256 prize);

    /**
     * @param vrfCoordinatorAddress VRF 协调器地址
     * @param _subscriptionId 订阅 ID (注意：V2 中通常是 uint64)
     * @param _keyHash 密钥哈希（Gas Lane）
     * @param _entryFee 入场费（Wei）
     */
    constructor(
        address vrfCoordinatorAddress,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2(vrfCoordinatorAddress) Ownable(msg.sender) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // --- 外部/公共函数 ---

    /**
     * @dev 参与彩票
     */
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH to enter");
        
        players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender, msg.value);
    }

    /**
     * @dev 开始彩票
     */
    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery already started");
        
        lotteryState = LOTTERY_STATE.OPEN;
        emit LotteryStarted();
    }

    /**
     * @dev 结束彩票并请求随机数
     */
    function endLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(players.length > 0, "No players in lottery");
        
        lotteryState = LOTTERY_STATE.CALCULATING;
        
        // 调用标准 VRF V2 的请求方法
        latestRequestId = i_vrfCoordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        
        emit RandomnessRequested(latestRequestId);
        emit LotteryEnded();
    }

    /**
     * @dev VRF 回调函数
     */
    function fulfillRandomWords(
        uint256 /* requestId */, 
        uint256[] memory randomWords
    ) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not calculating winner");
        require(randomWords.length > 0, "No random words");

        // 1. 确定获胜者
        uint256 indexOfWinner = randomWords[0] % players.length;
        recentWinner = players[indexOfWinner];
        
        // 2. 发送奖金
        uint256 prize = address(this).balance;
        (bool success, ) = recentWinner.call{value: prize}("");
        require(success, "Prize transfer failed");
        
        // 3. 重置状态
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        
        emit WinnerPicked(recentWinner, prize);
    }

    // --- 辅助查询函数 ---

    function getNumberOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function getPrizePool() public view returns (uint256) {
        return address(this).balance;
    }
}