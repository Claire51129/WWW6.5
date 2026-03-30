// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title ChainlinkVRFLottery
 * @dev Day 22 作业：Chainlink VRF 可验证随机数抽奖合约
 */
contract ChainlinkVRFLottery is VRFConsumerBaseV2Plus {
    
    // VRF 配置
    address constant VRF_COORDINATOR_SEPOLIA = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    
    // 状态变量
    address[] public participants;
    mapping(address => bool) public hasParticipated;
    uint256 public currentRoundId;
    
    enum LotteryState { OPEN, CALCULATING, CLOSED }
    LotteryState public lotteryState;
    
    struct LotteryRound {
        uint256 requestId;
        address[] participants;
        address winner;
        uint256 randomNumber;
        bool fulfilled;
        uint256 prizeAmount;
    }
    mapping(uint256 => LotteryRound) public lotteryRounds;
    
    // 事件
    event ParticipantEntered(address indexed participant, uint256 roundId);
    event RandomnessRequested(uint256 indexed requestId, uint256 roundId);
    event RandomnessFulfilled(uint256 indexed requestId, uint256 randomNumber);
    event WinnerPicked(uint256 indexed roundId, address indexed winner, uint256 prizeAmount);
    
    modifier inState(LotteryState _state) {
        require(lotteryState == _state, "Invalid state");
        _;
    }
    
    constructor(uint256 _subscriptionId) 
        VRFConsumerBaseV2Plus(VRF_COORDINATOR_SEPOLIA) 
    {
        subscriptionId = _subscriptionId;
        lotteryState = LotteryState.OPEN;
        currentRoundId = 1;
    }
    
    // 参与抽奖
    function enter() external payable inState(LotteryState.OPEN) {
        require(msg.value >= 0.001 ether, "Min 0.001 ETH");
        require(!hasParticipated[msg.sender], "Already in");
        
        participants.push(msg.sender);
        hasParticipated[msg.sender] = true;
        emit ParticipantEntered(msg.sender, currentRoundId);
    }
    
    // 请求随机数（开启抽奖）- 使用父合约的 onlyOwner
    function requestRandomWinner() 
        external 
        onlyOwner 
        inState(LotteryState.OPEN) 
        returns (uint256 requestId) 
    {
        require(participants.length > 0, "No participants");
        
        lotteryState = LotteryState.CALCULATING;
        
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        
        lotteryRounds[currentRoundId] = LotteryRound({
            requestId: requestId,
            participants: participants,
            winner: address(0),
            randomNumber: 0,
            fulfilled: false,
            prizeAmount: address(this).balance
        });
        
        emit RandomnessRequested(requestId, currentRoundId);
    }
    
    // VRF 回调函数
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        LotteryRound storage round = lotteryRounds[currentRoundId];
        require(round.requestId == _requestId, "Wrong request");
        require(!round.fulfilled, "Done");
        
        uint256 randomNumber = _randomWords[0];
        round.randomNumber = randomNumber;
        
        uint256 winnerIndex = randomNumber % round.participants.length;
        address winner = round.participants[winnerIndex];
        round.winner = winner;
        round.fulfilled = true;
        
        emit RandomnessFulfilled(_requestId, randomNumber);
        emit WinnerPicked(currentRoundId, winner, round.prizeAmount);
        
        (bool success, ) = payable(winner).call{value: round.prizeAmount}("");
        require(success, "Transfer fail");
        
        _resetRound();
    }
    
    function _resetRound() internal {
        for (uint i = 0; i < participants.length; i++) {
            hasParticipated[participants[i]] = false;
        }
        delete participants;
        lotteryState = LotteryState.OPEN;
        currentRoundId++;
    }
    
    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }
    
    function getPrizePool() external view returns (uint256) {
        return address(this).balance;
    }
    
    receive() external payable {}
}