// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ========== 1. 手动定义 Chainlink VRF 接口 ==========
interface VRFCoordinatorV2Interface {
    function requestRandomWords(
        bytes32 keyHash,
        uint256 subscriptionId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

// ========== 2. 手动定义 Chainlink VRF 消费者基类 ==========
abstract contract VRFConsumerBaseV2 {
    address internal immutable vrfCoordinator;   // 存储 VRF 协调器地址

    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
}

// ========== 3. 手动定义 Ownable 基础合约 ==========
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ========== 4. 主合约：去中心化彩票 ==========
contract DecentralisedLottery is VRFConsumerBaseV2, Ownable {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    
    LOTTERY_STATE public lotteryState;
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;
    
    // Chainlink VRF 配置（注意变量名不要与基类中的 vrfCoordinator 冲突）
    VRFCoordinatorV2Interface private vrfCoordinatorInterface;   // 改为新名字
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;
    
    // 事件
    event LotteryEntered(address indexed player, uint256 entryFee);
    event LotteryStarted();
    event LotteryEnded();
    event RandomnessRequested(uint256 indexed requestId);
    event WinnerPicked(address indexed winner, uint256 prize);
    
    constructor(
        address vrfCoordinatorAddress,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2(vrfCoordinatorAddress) Ownable(msg.sender) {
        // 基类已经存储了 vrfCoordinator 地址（不可变），
        // 这里将接口指向同一个地址
        vrfCoordinatorInterface = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }
    
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH to enter");
        players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender, msg.value);
    }
    
    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery already started");
        lotteryState = LOTTERY_STATE.OPEN;
        emit LotteryStarted();
    }
    
    function endLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(players.length > 0, "No players in lottery");
        lotteryState = LOTTERY_STATE.CALCULATING;
        latestRequestId = vrfCoordinatorInterface.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit RandomnessRequested(latestRequestId);
        emit LotteryEnded();
    }
    
  function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
    require(lotteryState == LOTTERY_STATE.CALCULATING, "Not calculating winner");
    require(randomWords.length > 0, "No random words received");
    uint256 indexOfWinner = randomWords[0] % players.length;
    recentWinner = players[indexOfWinner];
    uint256 prize = address(this).balance;
    (bool success, ) = recentWinner.call{value: prize}("");
    require(success, "Prize transfer failed");
    players = new address payable[](0);
    lotteryState = LOTTERY_STATE.CLOSED;
    emit WinnerPicked(recentWinner, prize);
}
    
    // 查询函数
    function getNumberOfPlayers() public view returns (uint256) { return players.length; }
    function getPlayers() public view returns (address payable[] memory) { return players; }
    function getPrizePool() public view returns (uint256) { return address(this).balance; }
    function isPlayer(address _player) public view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == _player) return true;
        }
        return false;
    }
    function getLotteryState() public view returns (string memory) {
        if (lotteryState == LOTTERY_STATE.OPEN) return "OPEN";
        if (lotteryState == LOTTERY_STATE.CLOSED) return "CLOSED";
        if (lotteryState == LOTTERY_STATE.CALCULATING) return "CALCULATING";
        return "UNKNOWN";
    }
    
    // 管理员功能
    function setEntryFee(uint256 _newEntryFee) public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Cannot change fee during lottery");
        entryFee = _newEntryFee;
    }
    function setVRFConfig(bytes32 _keyHash, uint32 _callbackGasLimit, uint16 _requestConfirmations) public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Cannot change config during lottery");
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
    }
    function emergencyWithdraw() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery must be closed");
        require(players.length == 0, "Players still in lottery");
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
