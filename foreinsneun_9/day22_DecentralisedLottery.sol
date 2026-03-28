//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface VRFCoordinatorV2Interface {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
    function addConsumer(uint64 subId, address consumer) external;
    function removeConsumer(uint64 subId, address consumer) external;
    function createSubscription() external returns (uint64 subId);
    function getSubscription(uint64 subId)
        external view returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );
}

abstract contract VRFConsumerBaseV2Plus {
    address private vrfCoordinator;
    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }
    function rawFulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external {
        require(msg.sender == vrfCoordinator, "Only coordinator");
        fulfillRandomWords(requestId, randomWords);
    }
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
}
import "@openzeppelin/contracts/access/Ownable.sol";
contract DecentralisedLottery is VRFConsumerBaseV2Plus, Ownable {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }    
    LOTTERY_STATE public lotteryState;
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;
    mapping(address => uint256) public playerRound;
    uint256 public currentRound;
    VRFCoordinatorV2Interface private vrfCoordinator;

    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    uint256 public latestRequestId;
    event LotteryEntered(address indexed player, uint256 entryFee);
    event LotteryStarted();
    event LotteryEnded();
    event RandomnessRequested(uint256 indexed requestId);
    event WinnerPicked(address indexed winner, uint256 prize);  

    constructor(
        address vrfCoordinatorAddress,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinatorAddress) Ownable(msg.sender) {
        vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(playerRound[msg.sender] != currentRound, "Already entered");
        require(msg.value >= entryFee, "Not enough ETH to enter");
        players.push(payable(msg.sender));
        playerRound[msg.sender] = currentRound;
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
        latestRequestId = vrfCoordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );       
        emit RandomnessRequested(latestRequestId);
        emit LotteryEnded();
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) 
        internal override {      
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not calculating winner");
        require(randomWords.length > 0, "No random words received");
        uint256 indexOfWinner = randomWords[0] % players.length;
        recentWinner = players[indexOfWinner];
        uint256 prize = address(this).balance;
        lotteryState = LOTTERY_STATE.CLOSED;
        (bool success, ) = recentWinner.call{value: prize}("");
        require(success, "Prize transfer failed");
        players = new address payable[](0);
        currentRound ++;
        emit WinnerPicked(recentWinner, prize);
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getPrizePool() public view returns (uint256) {
        return address(this).balance;
    }

    function isPlayer(address _player) public view returns (bool) {
        return playerRound[_player] == currentRound;
    }

    function setEntryFee(uint256 _newEntryFee) public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Cannot change fee during lottery");
        entryFee = _newEntryFee;
    }

    function setVRFConfig(
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
    ) public onlyOwner {
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
    
    function getLotteryState() public view returns (string memory) {
        if (lotteryState == LOTTERY_STATE.OPEN) return "OPEN";
        if (lotteryState == LOTTERY_STATE.CLOSED) return "CLOSED";
        if (lotteryState == LOTTERY_STATE.CALCULATING) return "CALCULATING";
        return "UNKNOWN";
    }
}