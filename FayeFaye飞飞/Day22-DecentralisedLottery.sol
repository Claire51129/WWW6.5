// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedLottery {
    
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    
    LOTTERY_STATE public lotteryState;
    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;
    address public owner;

    event LotteryEntered(address indexed player, uint256 amount);
    event LotteryStarted();
    event WinnerPicked(address indexed winner, uint256 prize);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _entryFee) {
        owner = msg.sender;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // 参与
    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");

        players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender, msg.value);
    }

    // 开启彩票
    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Already started");
        lotteryState = LOTTERY_STATE.OPEN;
        emit LotteryStarted();
    }

    // 抽奖（替代 VRF）
    function pickWinner() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Not open");
        require(players.length > 0, "No players");

        lotteryState = LOTTERY_STATE.CALCULATING;

        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, players.length)
            )
        );

        uint256 index = random % players.length;
        recentWinner = players[index];

        uint256 prize = address(this).balance;
        (bool success, ) = recentWinner.call{value: prize}("");
        require(success, "Transfer failed");

        delete players;
        lotteryState = LOTTERY_STATE.CLOSED;

        emit WinnerPicked(recentWinner, prize);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}