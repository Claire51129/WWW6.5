// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {

    enum LotteryState { OPEN, CLOSED, CALCULATING }
    LotteryState public lotteryState;

    address payable[] public players;
    address public recentWinner;
    address[] public winners;
    uint256 public entryFee;
    uint256 public minPlayers;
    uint256 public roundNumber;

    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;

    event LotteryStarted(uint256 roundNumber);
    event PlayerEntered(address indexed player, uint256 totalPlayers);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 roundNumber);
    event LotteryEnded(uint256 requestId);

    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee,
        uint256 _minPlayers
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        minPlayers = _minPlayers > 0 ? _minPlayers : 2;
        lotteryState = LotteryState.CLOSED;
        roundNumber = 0;
    }

    function enter() external payable {
        require(lotteryState == LotteryState.OPEN, "Lottery is not open");
        require(msg.value >= entryFee, "Entry fee not met");
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, players.length);
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LotteryState.CLOSED, "Cannot start: not closed");
        lotteryState = LotteryState.OPEN;
        roundNumber++;
        emit LotteryStarted(roundNumber);
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LotteryState.OPEN, "Lottery is not open");
        require(players.length >= minPlayers, "Not enough players");
        lotteryState = LotteryState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
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
        emit LotteryEnded(latestRequestId);
    }

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LotteryState.CALCULATING, "Not in calculating state");
        require(players.length > 0, "No players");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];

        recentWinner = winner;
        winners.push(winner);

        players = new address payable[](0);
        lotteryState = LotteryState.CLOSED;

        uint256 prize = address(this).balance;
        (bool sent, ) = winner.call{value: prize}("");
        require(sent, "Prize transfer failed");

        emit WinnerSelected(winner, prize, roundNumber);
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }

    function getWinners() external view returns (address[] memory) {
        return winners;
    }

    function getPlayerCount() external view returns (uint256) {
        return players.length;
    }

    function getPrizePool() external view returns (uint256) {
        return address(this).balance;
    }
}
