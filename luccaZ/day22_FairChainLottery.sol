//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//fulfillRandomWords is called by the VRF coordinator when it receives a valid VRF proof. 
//This function is where you would implement the logic to determine the winner of the lottery and distribute the prize.
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
//helper library for constructing the request parameters for the VRF request. 
//It provides a convenient way to create the necessary data structure for making a VRF request, including the key hash, subscription ID, gas limit, and other parameters.
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

//inherit from VRFConsumerBaseV2Plus to create a contract that can request random numbers from Chainlink VRF
//and handle the response in fulfillRandomWords.
contract FairChainLottery is VRFConsumerBaseV2Plus {
  enum LOTTERY_STATE {
    OPEN,
    CLOSED,
    CALCULATING //requesting random number and determining winner
  }
  LOTTERY_STATE public lotteryState;

  address payable[] public players;
  address public recentWinner;
  uint256 public entryFee;

  //Chainlink VRF config
  uint256 public subscriptionId; //chainlink VRF subscription ID
  bytes32 public keyHash; //run the VRF request with the specified key hash
  uint32 public callbackGasLimit = 100000; //gas limit for the callback function fulfillRandomWords
  uint16 public requestConfirmations = 3; //wait for 3 confirmations before the VRF response is considered valid
  uint32 public numWords = 1; //how many random words we want to request from the VRF
  uint256 public latestRequestId;//store the latest VRF request ID for reference

  constructor (
    address vrfCoordinator, 
    //the address of the Chainlink VRF coordinator contract that will handle the random number requests and responses
    uint256 _subscriptionId,
    //your chainlink VRF subscription ID
    bytes32 _keyHash,
    //defines the specific VRF key pair that will be used to generate the random number
    uint256 _entryFee
  ) VRFConsumerBaseV2Plus(vrfCoordinator) {
    subscriptionId = _subscriptionId;
    keyHash = _keyHash;
    entryFee = _entryFee;
    lotteryState = LOTTERY_STATE.CLOSED;
  }

  function enter() public payable {
    require(lotteryState == LOTTERY_STATE.OPEN, "Lottery is not open");
    require(msg.value >= entryFee, "Not enough ETH to enter");

    players.push(payable(msg.sender));
  }

  function startLottery() external onlyOwner {
    require(lotteryState == LOTTERY_STATE.CLOSED, "Lottery is already open");
    lotteryState = LOTTERY_STATE.OPEN;
  }

  function endLottery() external onlyOwner {
    require(lotteryState == LOTTERY_STATE.OPEN, "Lottery is not open");
    lotteryState = LOTTERY_STATE.CALCULATING;

    // construct the VRF request parameters using the VRFV2PlusClient library
    VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
      keyHash: keyHash,
      subId: subscriptionId,
      requestConfirmations: requestConfirmations,
      callbackGasLimit: callbackGasLimit,
      numWords: numWords,
      extraArgs: VRFV2PlusClient._argsToBytes(
        //VRFV2PlusClient._argsToBytes is a helper function that converts the extra arguments
        //for the VRF request into a bytes format that can be included in the request.
        VRFV2PlusClient.ExtraArgsV1({ 
          //a struct from VRFV2PlusClient library that allows you to specify additional parameters for the VRF request
          //this line means that the VRF request will be paid for using the native token of the blockchain (e.g., ETH on Ethereum) instead of LINK tokens.
          nativePayment: true
        })
        )
    });
    //send the VRF request and store the latest request ID
    //the base contract VRFConsumerBaseV2Plus stores a reference to the VRF coordinator
    //address internal s_vrfCoordinator;
    //the base contract stores vrfCoordinator in s_vrfCoordinator
    latestRequestId = s_vrfCoordinator.requestRandomWords(req);
  }

  function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
    require(lotteryState == LOTTERY_STATE.CALCULATING, "Not calculating winner");
    
    uint256 winnerIndex = randomWords[0] % players.length;
    address payable winner = players[winnerIndex];
    recentWinner = winner;

    players = new address payable[](0); // Reset players for next round
    lotteryState = LOTTERY_STATE.CLOSED;

    (bool sent, ) = winner.call{value: address(this).balance}("");
    require(sent, "Failed to send prize to winner");
  }

  function getPlayers() external view returns (address payable[] memory) {
    return players;
  }
}