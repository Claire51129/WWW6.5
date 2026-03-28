// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * 为了在 GitHub 直接编译，我们手动定义必要的接口和基础合约
 */

// 模拟 Ownable 权限控制
abstract contract Ownable {
    address private _owner;
    
    constructor(address initialOwner) { 
        _owner = initialOwner; 
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
}

// Chainlink VRF 接口
interface IVRFCoordinatorV2 {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

// VRF 消费者基础合约
abstract contract VRFConsumerBaseV2 {
    address internal vrfCoordinator;
    
    constructor(address _vrfCoordinator) { 
        vrfCoordinator = _vrfCoordinator; 
    }
    
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
    
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        require(msg.sender == vrfCoordinator, "Only coordinator can fulfill");
        fulfillRandomWords(requestId, randomWords);
    }
}

contract DecentralisedLottery is VRFConsumerBaseV2, Ownable {
    // 状态定义
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;

    address payable[] public players;
    uint256 public entryFee;
    
    // VRF 配置
    uint64 public subscriptionId;
    bytes32 public keyHash;

    event LotteryEntered(address indexed player, uint256 amount);
    event WinnerPicked(address indexed winner, uint256 prize);

    constructor(
        address vrfCoordinatorAddress,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2(vrfCoordinatorAddress) Ownable(msg.sender) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        
        players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender, msg.value);
    }

    function startLottery() public onlyOwner {
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Not open");
        lotteryState = LOTTERY_STATE.CALCULATING;
        
        IVRFCoordinatorV2(vrfCoordinator).requestRandomWords(
            keyHash,
            subscriptionId,
            3, // confirmations
            100000, // gas limit
            1 // num words
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Lottery not in calculating state");
        require(players.length > 0, "No players in lottery");

        uint256 indexOfWinner = randomWords[0] % players.length;
        address payable winner = players[indexOfWinner];
        uint256 prize = address(this).balance;
        
        (bool success, ) = winner.call{value: prize}("");
        require(success, "Transfer failed");

        // 重置状态
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        emit WinnerPicked(winner, prize);
    }
}
